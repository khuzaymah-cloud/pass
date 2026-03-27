from datetime import date, timedelta, datetime, timezone
from decimal import Decimal
from typing import List, Optional, Dict

from fastapi import APIRouter, Depends, Query, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc

from app.database import get_db
from app.dependencies import require_admin, get_country
from app.models.user import User
from app.models.gym import Gym
from app.models.country import Country
from app.models.plan import Plan
from app.models.subscription import Subscription
from app.models.checkin import Checkin
from app.models.payment import Payment
from app.models.gym_settlement import GymSettlement
from app.schemas.country import CountryOut
from app.schemas.user import UserOut
from app.schemas.gym import GymOut
from app.schemas.plan import PlanOut
from app.schemas.subscription import SubscriptionOut
from app.schemas.checkin import CheckinOut
from app.schemas.payment import PaymentOut
from app.services import settlement_service, subscription_service

router = APIRouter()


# ── Request Bodies ───────────────────────────────────────────────

class CreateUserBody(BaseModel):
    phone: str
    full_name: str
    email: Optional[str] = None
    role: str = "member"
    gender: Optional[str] = None


class UpdateUserBody(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None
    full_name: Optional[str] = None
    email: Optional[str] = None
    gender: Optional[str] = None


class CreateGymBody(BaseModel):
    name_en: str
    name_ar: Optional[str] = None
    tier: str = "standard"
    address: str
    lat: float
    lng: float
    phone: Optional[str] = None
    description_en: Optional[str] = None
    description_ar: Optional[str] = None
    opening_hours: Dict = {}
    amenities: Optional[List[str]] = None
    categories: Optional[List[str]] = None
    is_active: bool = False


class UpdateGymBody(BaseModel):
    name_en: Optional[str] = None
    name_ar: Optional[str] = None
    tier: Optional[str] = None
    address: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    phone: Optional[str] = None
    description_en: Optional[str] = None
    description_ar: Optional[str] = None
    opening_hours: Optional[Dict] = None
    amenities: Optional[List[str]] = None
    categories: Optional[List[str]] = None
    is_active: Optional[bool] = None
    is_featured: Optional[bool] = None


class CreatePlanBody(BaseModel):
    tier: str
    name_en: str
    name_ar: str
    price_local: str
    max_visits: int = 30
    validity_days: int = 30
    gym_tier_access: str
    features_en: List[str] = []
    features_ar: List[str] = []
    is_active: bool = True
    sort_order: int = 0


class UpdatePlanBody(BaseModel):
    tier: Optional[str] = None
    name_en: Optional[str] = None
    name_ar: Optional[str] = None
    price_local: Optional[str] = None
    max_visits: Optional[int] = None
    validity_days: Optional[int] = None
    gym_tier_access: Optional[str] = None
    features_en: Optional[List[str]] = None
    features_ar: Optional[List[str]] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


# ── Dashboard Stats ──────────────────────────────────────────────

@router.get("/stats")
async def dashboard_stats(
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    users_count = await db.scalar(
        select(func.count(User.id)).where(User.country_id == country.id, User.deleted_at.is_(None))
    )
    gyms_count = await db.scalar(
        select(func.count(Gym.id)).where(Gym.country_id == country.id, Gym.deleted_at.is_(None))
    )
    active_subs = await db.scalar(
        select(func.count(Subscription.id)).where(
            Subscription.country_id == country.id, Subscription.status == "active"
        )
    )
    total_checkins = await db.scalar(select(func.count(Checkin.id)))
    total_revenue = await db.scalar(
        select(func.coalesce(func.sum(Payment.total_charged), 0)).where(
            Payment.status == "success"
        )
    )
    pending_subs = await db.scalar(
        select(func.count(Subscription.id)).where(
            Subscription.country_id == country.id, Subscription.status == "pending"
        )
    )
    return {
        "users": users_count or 0,
        "gyms": gyms_count or 0,
        "active_subscriptions": active_subs or 0,
        "pending_subscriptions": pending_subs or 0,
        "total_checkins": total_checkins or 0,
        "total_revenue": str(total_revenue or 0),
    }


# ── Users ────────────────────────────────────────────────────────

@router.get("/users", response_model=List[UserOut])
async def list_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    role: Optional[str] = None,
    search: Optional[str] = None,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    q = select(User).where(User.country_id == country.id, User.deleted_at.is_(None))
    if role:
        q = q.where(User.role == role)
    if search:
        q = q.where(User.phone.ilike(f"%{search}%") | User.full_name.ilike(f"%{search}%"))
    q = q.order_by(desc(User.created_at)).offset(skip).limit(limit)
    result = await db.execute(q)
    return list(result.scalars().all())


@router.post("/users", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    body: CreateUserBody,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    user = User(
        phone=body.phone,
        full_name=body.full_name,
        email=body.email,
        role=body.role,
        gender=body.gender,
        country_id=country.id,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return user


@router.get("/users/{user_id}", response_model=UserOut)
async def get_user(
    user_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user or user.deleted_at:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.patch("/users/{user_id}")
async def update_user(
    user_id: str,
    body: UpdateUserBody,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if body.role is not None:
        user.role = body.role
    if body.is_active is not None:
        user.is_active = body.is_active
    if body.full_name is not None:
        user.full_name = body.full_name
    if body.email is not None:
        user.email = body.email
    if body.gender is not None:
        user.gender = body.gender
    await db.flush()
    return {"id": str(user.id), "role": user.role, "is_active": user.is_active}


@router.delete("/users/{user_id}")
async def soft_delete_user(
    user_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.deleted_at = datetime.now(timezone.utc)
    user.is_active = False
    await db.flush()
    return {"id": str(user.id), "deleted": True}


# ── Gyms ─────────────────────────────────────────────────────────

@router.get("/gyms", response_model=List[GymOut])
async def list_gyms(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    tier: Optional[str] = None,
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    q = select(Gym).where(Gym.country_id == country.id, Gym.deleted_at.is_(None))
    if tier:
        q = q.where(Gym.tier == tier)
    if is_active is not None:
        q = q.where(Gym.is_active == is_active)
    if search:
        q = q.where(Gym.name_en.ilike(f"%{search}%") | Gym.name_ar.ilike(f"%{search}%"))
    q = q.order_by(desc(Gym.created_at)).offset(skip).limit(limit)
    result = await db.execute(q)
    return list(result.scalars().all())


@router.post("/gyms", response_model=GymOut, status_code=status.HTTP_201_CREATED)
async def create_gym(
    body: CreateGymBody,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    gym = Gym(
        country_id=country.id,
        name_en=body.name_en,
        name_ar=body.name_ar,
        tier=body.tier,
        address=body.address,
        lat=body.lat,
        lng=body.lng,
        phone=body.phone,
        description_en=body.description_en,
        description_ar=body.description_ar,
        opening_hours=body.opening_hours,
        amenities=body.amenities,
        categories=body.categories,
        is_active=body.is_active,
    )
    db.add(gym)
    await db.flush()
    await db.refresh(gym)
    return gym


@router.get("/gyms/{gym_id}", response_model=GymOut)
async def get_gym(
    gym_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    gym = await db.get(Gym, gym_id)
    if not gym or gym.deleted_at:
        raise HTTPException(status_code=404, detail="Gym not found")
    return gym


@router.patch("/gyms/{gym_id}")
async def update_gym(
    gym_id: str,
    body: UpdateGymBody,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    gym = await db.get(Gym, gym_id)
    if not gym or gym.deleted_at:
        raise HTTPException(status_code=404, detail="Gym not found")
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(gym, field, value)
    await db.flush()
    await db.refresh(gym)
    return gym


@router.patch("/gyms/{gym_id}/approve")
async def approve_gym(
    gym_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    gym = await db.get(Gym, gym_id)
    if not gym:
        raise HTTPException(status_code=404, detail="Gym not found")
    gym.is_active = True
    await db.flush()
    return {"id": str(gym.id), "is_active": True}


@router.delete("/gyms/{gym_id}")
async def soft_delete_gym(
    gym_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    gym = await db.get(Gym, gym_id)
    if not gym:
        raise HTTPException(status_code=404, detail="Gym not found")
    gym.deleted_at = datetime.now(timezone.utc)
    gym.is_active = False
    await db.flush()
    return {"id": str(gym.id), "deleted": True}


# ── Plans ────────────────────────────────────────────────────────

@router.get("/plans", response_model=List[PlanOut])
async def list_plans(
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Plan).where(Plan.country_id == country.id).order_by(Plan.sort_order)
    )
    return list(result.scalars().all())


@router.post("/plans", response_model=PlanOut, status_code=status.HTTP_201_CREATED)
async def create_plan(
    body: CreatePlanBody,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    price = Decimal(body.price_local)
    plan = Plan(
        country_id=country.id,
        tier=body.tier,
        name_en=body.name_en,
        name_ar=body.name_ar,
        price_local=price,
        daily_rate=price / body.max_visits,
        max_visits=body.max_visits,
        validity_days=body.validity_days,
        gym_tier_access=body.gym_tier_access,
        features_en=body.features_en,
        features_ar=body.features_ar,
        is_active=body.is_active,
        sort_order=body.sort_order,
    )
    db.add(plan)
    await db.flush()
    await db.refresh(plan)
    return plan


@router.patch("/plans/{plan_id}")
async def update_plan(
    plan_id: str,
    body: UpdatePlanBody,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    plan = await db.get(Plan, plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    updates = body.model_dump(exclude_unset=True)
    if "price_local" in updates:
        updates["price_local"] = Decimal(updates["price_local"])
    for field, value in updates.items():
        setattr(plan, field, value)
    if "price_local" in updates or "max_visits" in updates:
        plan.daily_rate = plan.price_local / plan.max_visits
    await db.flush()
    await db.refresh(plan)
    return plan


# ── Subscriptions ────────────────────────────────────────────────

@router.get("/subscriptions", response_model=List[SubscriptionOut])
async def list_subscriptions(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    status_filter: Optional[str] = Query(None, alias="status"),
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    q = select(Subscription).where(Subscription.country_id == country.id)
    if status_filter:
        q = q.where(Subscription.status == status_filter)
    q = q.order_by(desc(Subscription.created_at)).offset(skip).limit(limit)
    result = await db.execute(q)
    return list(result.scalars().all())


@router.post("/subscriptions/{sub_id}/activate")
async def manual_activate(
    sub_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    sub = await subscription_service.get_subscription_by_id(sub_id, db)
    activated = await subscription_service.activate_subscription(sub, db)
    return {"id": str(activated.id), "status": activated.status}


@router.post("/expire-subscriptions")
async def trigger_expiry(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    count = await subscription_service.expire_due_subscriptions(db)
    return {"expired": count}


# ── Checkins ─────────────────────────────────────────────────────

@router.get("/checkins", response_model=List[CheckinOut])
async def list_checkins(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    gym_id: Optional[str] = None,
    user_id: Optional[str] = None,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    q = select(Checkin)
    if gym_id:
        q = q.where(Checkin.gym_id == gym_id)
    if user_id:
        q = q.where(Checkin.user_id == user_id)
    q = q.order_by(desc(Checkin.checked_in_at)).offset(skip).limit(limit)
    result = await db.execute(q)
    return list(result.scalars().all())


# ── Payments ─────────────────────────────────────────────────────

@router.get("/payments", response_model=List[PaymentOut])
async def list_payments(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    status_filter: Optional[str] = Query(None, alias="status"),
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    q = select(Payment)
    if status_filter:
        q = q.where(Payment.status == status_filter)
    q = q.order_by(desc(Payment.created_at)).offset(skip).limit(limit)
    result = await db.execute(q)
    return list(result.scalars().all())


# ── Countries ────────────────────────────────────────────────────

@router.get("/countries", response_model=List[CountryOut])
async def list_countries(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Country).order_by(Country.id))
    return list(result.scalars().all())


@router.patch("/countries/{country_id}")
async def toggle_country(
    country_id: int,
    is_active: bool = True,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    country = await db.get(Country, country_id)
    if not country:
        raise HTTPException(status_code=404, detail="Country not found")
    country.is_active = is_active
    await db.flush()
    return {"id": country.id, "code": country.code, "is_active": country.is_active}


# ── Settlements ──────────────────────────────────────────────────

@router.get("/settlements")
async def list_settlements(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=200),
    status_filter: Optional[str] = Query(None, alias="status"),
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    q = select(GymSettlement)
    if status_filter:
        q = q.where(GymSettlement.status == status_filter)
    q = q.order_by(desc(GymSettlement.period_start)).offset(skip).limit(limit)
    result = await db.execute(q)
    settlements = result.scalars().all()
    return [
        {
            "id": str(s.id),
            "gym_id": str(s.gym_id),
            "total_visits": s.total_visits,
            "total_amount": str(s.total_amount),
            "status": s.status,
            "period_start": str(s.period_start),
            "period_end": str(s.period_end),
            "paid_at": str(s.paid_at) if s.paid_at else None,
        }
        for s in settlements
    ]


@router.post("/settlements/run")
async def run_settlement(
    period_start: Optional[str] = None,
    period_end: Optional[str] = None,
    admin: User = Depends(require_admin),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    if not period_start:
        today = date.today()
        first_of_month = today.replace(day=1)
        end = first_of_month - timedelta(days=1)
        start = end.replace(day=1)
    else:
        start = date.fromisoformat(period_start)
        end = date.fromisoformat(period_end) if period_end else start.replace(day=28)
    settlements = await settlement_service.run_monthly_settlement(country, start, end, db)
    return {"count": len(settlements), "period": f"{start} to {end}"}


@router.patch("/settlements/{settlement_id}/pay")
async def mark_settlement_paid(
    settlement_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    settlement = await db.get(GymSettlement, settlement_id)
    if not settlement:
        raise HTTPException(status_code=404, detail="Settlement not found")
    settlement.status = "paid"
    settlement.paid_at = datetime.now(timezone.utc)
    await db.flush()
    return {"id": str(settlement.id), "status": "paid"}
