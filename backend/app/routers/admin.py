from datetime import date, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.database import get_db
from app.dependencies import require_admin, get_country
from app.models.user import User
from app.models.gym import Gym
from app.models.country import Country
from app.models.subscription import Subscription
from app.models.checkin import Checkin
from app.models.gym_settlement import GymSettlement
from app.schemas.country import CountryOut
from app.services import settlement_service, subscription_service

router = APIRouter()


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
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Country not found")
    country.is_active = is_active
    await db.flush()
    return {"id": country.id, "code": country.code, "is_active": country.is_active}


@router.patch("/gyms/{gym_id}/approve")
async def approve_gym(
    gym_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    gym = await db.get(Gym, gym_id)
    if not gym:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gym not found")
    gym.is_active = True
    await db.flush()
    return {"id": str(gym.id), "is_active": True}


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
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Settlement not found")
    from datetime import datetime, timezone
    settlement.status = "paid"
    settlement.paid_at = datetime.now(timezone.utc)
    await db.flush()
    return {"id": str(settlement.id), "status": "paid"}


@router.post("/subscriptions/{sub_id}/activate")
async def manual_activate(
    sub_id: str,
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    sub = await subscription_service.get_subscription_by_id(sub_id, db)
    activated = await subscription_service.activate_subscription(sub, db)
    return {"id": str(activated.id), "status": activated.status}


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
    total_checkins = await db.scalar(
        select(func.count(Checkin.id))
    )
    return {
        "users": users_count or 0,
        "gyms": gyms_count or 0,
        "active_subscriptions": active_subs or 0,
        "total_checkins": total_checkins or 0,
    }


@router.post("/expire-subscriptions")
async def trigger_expiry(
    admin: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    count = await subscription_service.expire_due_subscriptions(db)
    return {"expired": count}
