from typing import List, Optional
from datetime import date, datetime, timezone
from fastapi import APIRouter, Depends, Query, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.dependencies import get_country, get_current_user, require_gym_partner
from app.models.country import Country
from app.models.user import User
from app.models.gym import Gym
from app.models.checkin import Checkin
from app.models.subscription import Subscription
from app.models.plan import Plan
from app.schemas.gym import GymOut, GymCreate, GymUpdate
from app.services import gym_service, checkin_service, subscription_service, plan_service

router = APIRouter()


class ScanCheckinRequest(BaseModel):
    user_id: str
    subscription_id: str


class MemberCheckinRequest(BaseModel):
    gym_id: str


# ─── Gym partner endpoints (must be before /{gym_id}) ───

@router.get("/my-gym", response_model=GymOut)
async def get_my_gym(
    user: User = Depends(require_gym_partner),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Gym).where(Gym.partner_id == user.id, Gym.deleted_at.is_(None))
    )
    gym = result.scalar_one_or_none()
    if not gym:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No gym linked to your account")
    return gym


@router.get("/my-gym/stats")
async def get_my_gym_stats(
    user: User = Depends(require_gym_partner),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Gym).where(Gym.partner_id == user.id, Gym.deleted_at.is_(None))
    )
    gym = result.scalar_one_or_none()
    if not gym:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No gym linked to your account")

    today = date.today()
    now = datetime.now(timezone.utc)
    month_start = today.replace(day=1)

    # Today's visits
    today_res = await db.execute(
        select(func.count(Checkin.id)).where(
            Checkin.gym_id == gym.id,
            func.date(Checkin.checked_in_at) == today,
            Checkin.status == "completed",
        )
    )
    visits_today = today_res.scalar() or 0

    # This month's visits
    month_res = await db.execute(
        select(func.count(Checkin.id)).where(
            Checkin.gym_id == gym.id,
            func.date(Checkin.checked_in_at) >= month_start,
            Checkin.status == "completed",
        )
    )
    visits_month = month_res.scalar() or 0

    # Total all-time visits
    total_res = await db.execute(
        select(func.count(Checkin.id)).where(
            Checkin.gym_id == gym.id,
            Checkin.status == "completed",
        )
    )
    visits_total = total_res.scalar() or 0

    # This month's earnings
    earnings_res = await db.execute(
        select(func.coalesce(func.sum(Checkin.daily_rate_paid), 0)).where(
            Checkin.gym_id == gym.id,
            func.date(Checkin.checked_in_at) >= month_start,
            Checkin.status == "completed",
        )
    )
    earnings_month = float(earnings_res.scalar() or 0)

    # Recent check-ins (last 20)
    recent_res = await db.execute(
        select(
            Checkin.id,
            Checkin.checked_in_at,
            Checkin.daily_rate_paid,
            Checkin.plan_tier,
            User.full_name,
            User.phone,
        )
        .join(User, Checkin.user_id == User.id)
        .where(Checkin.gym_id == gym.id, Checkin.status == "completed")
        .order_by(Checkin.checked_in_at.desc())
        .limit(20)
    )
    recent = [
        {
            "id": str(r.id),
            "checked_in_at": r.checked_in_at.isoformat(),
            "daily_rate_paid": float(r.daily_rate_paid),
            "plan_tier": r.plan_tier,
            "member_name": r.full_name,
            "member_phone": r.phone,
        }
        for r in recent_res.all()
    ]

    return {
        "gym_id": str(gym.id),
        "gym_name": gym.name_en,
        "visits_today": visits_today,
        "visits_month": visits_month,
        "visits_total": visits_total,
        "earnings_month": earnings_month,
        "recent_checkins": recent,
    }


@router.post("/scan-checkin")
async def scan_checkin(
    body: ScanCheckinRequest,
    user: User = Depends(require_gym_partner),
    db: AsyncSession = Depends(get_db),
):
    # Find the gym partner's gym
    result = await db.execute(
        select(Gym).where(Gym.partner_id == user.id, Gym.deleted_at.is_(None))
    )
    gym = result.scalar_one_or_none()
    if not gym:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No gym linked to your account")

    # Get the member
    member = await db.get(User, body.user_id)
    if not member or not member.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Member not found")

    # Get the subscription
    sub = await db.get(Subscription, body.subscription_id)
    if not sub or sub.user_id != member.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found")
    if sub.status != "active":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Subscription is not active")
    if subscription_service.is_expired(sub):
        sub.status = "expired"
        await db.flush()
        await db.commit()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Subscription has expired")

    plan = await plan_service.get_plan_by_id(str(sub.plan_id), db)
    try:
        checkin = await checkin_service.process_checkin(member, gym, sub, plan, db)
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    return {
        "status": "success",
        "member_name": member.full_name,
        "plan_tier": plan.tier,
        "visits_remaining": sub.visits_remaining,
        "daily_rate_paid": float(checkin.daily_rate_paid),
    }


@router.post("/member-checkin")
async def member_checkin(
    body: MemberCheckinRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Member scans gym QR → checks themselves in."""
    # Get the gym
    gym = await db.get(Gym, body.gym_id)
    if not gym or gym.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gym not found")

    # Get the member's active subscription
    result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == user.id,
            Subscription.status == "active",
        ).order_by(Subscription.created_at.desc())
    )
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No active subscription")
    if subscription_service.is_expired(sub):
        sub.status = "expired"
        await db.flush()
        await db.commit()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Subscription has expired")

    plan = await plan_service.get_plan_by_id(str(sub.plan_id), db)
    try:
        checkin = await checkin_service.process_checkin(user, gym, sub, plan, db)
        await db.commit()
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    return {
        "status": "success",
        "gym_name": gym.name_en or gym.name_ar,
        "plan_tier": plan.tier,
        "visits_remaining": sub.visits_remaining,
        "daily_rate_paid": float(checkin.daily_rate_paid),
    }


# ─── Network endpoints (before /{gym_id}) ───

TIER_HIERARCHY = {
    'silver': ['standard'],
    'gold': ['standard', 'gold'],
    'platinum': ['standard', 'gold', 'platinum'],
    'diamond': ['standard', 'gold', 'platinum', 'diamond'],
}


@router.get("/network-counts")
async def get_network_counts(
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    counts = {}
    for plan_tier, accessible in TIER_HIERARCHY.items():
        result = await db.execute(
            select(func.count(Gym.id)).where(
                Gym.country_id == country.id,
                Gym.is_active == True,
                Gym.deleted_at.is_(None),
                Gym.tier.in_(accessible),
            )
        )
        counts[plan_tier] = result.scalar() or 0
    return counts


@router.get("/network/{plan_tier}", response_model=List[GymOut])
async def get_network_gyms(
    plan_tier: str,
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    accessible = TIER_HIERARCHY.get(plan_tier)
    if not accessible:
        raise HTTPException(status_code=400, detail="Invalid tier")
    result = await db.execute(
        select(Gym).where(
            Gym.country_id == country.id,
            Gym.is_active == True,
            Gym.deleted_at.is_(None),
            Gym.tier.in_(accessible),
        ).order_by(Gym.name_en)
    )
    return list(result.scalars().all())


# ─── Public endpoints ───

@router.get("", response_model=List[GymOut])
async def list_gyms(
    tier: Optional[str] = None,
    featured: Optional[bool] = None,
    search: Optional[str] = None,
    limit: int = Query(50, le=100),
    offset: int = 0,
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    return await gym_service.list_gyms(country, db, tier=tier, is_featured=featured, search=search, limit=limit, offset=offset)


@router.get("/{gym_id}", response_model=GymOut)
async def get_gym(gym_id: str, db: AsyncSession = Depends(get_db)):
    return await gym_service.get_gym_by_id(gym_id, db)


@router.post("", response_model=GymOut)
async def create_gym(
    body: GymCreate,
    user: User = Depends(require_gym_partner),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    return await gym_service.create_gym(body.model_dump(), country, str(user.id), db)


@router.patch("/{gym_id}", response_model=GymOut)
async def update_gym(
    gym_id: str,
    body: GymUpdate,
    user: User = Depends(require_gym_partner),
    db: AsyncSession = Depends(get_db),
):
    gym = await gym_service.get_gym_by_id(gym_id, db)
    return await gym_service.update_gym(gym, body.model_dump(exclude_unset=True), db)
