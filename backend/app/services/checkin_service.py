import uuid
from datetime import date, datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.models.checkin import Checkin
from app.models.gym import Gym
from app.models.subscription import Subscription
from app.models.plan import Plan
from app.models.user import User
from app.core.exceptions import (
    SubscriptionNotActiveError,
    SubscriptionExpiredError,
    GymTierNotAllowedError,
    DuplicateCheckinError,
)
from app.services.subscription_service import is_expired

TIER_ORDER = ["standard", "gold", "platinum", "diamond"]


async def process_checkin(
    user: User,
    gym: Gym,
    subscription: Subscription,
    plan: Plan,
    db: AsyncSession,
) -> Checkin:
    # Step 1 — Validate subscription is active
    if subscription.status != "active":
        raise SubscriptionNotActiveError()
    if is_expired(subscription):
        subscription.status = "expired"
        await db.flush()
        raise SubscriptionExpiredError()

    # Step 2 — Validate gym tier access
    plan_ceiling = TIER_ORDER.index(plan.gym_tier_access)
    gym_tier_idx = TIER_ORDER.index(gym.tier)
    if gym_tier_idx > plan_ceiling:
        raise GymTierNotAllowedError(
            f"Your {plan.tier} plan does not include {gym.tier} gyms"
        )

    # Step 3 — Prevent duplicate (same gym, same calendar day)
    today = date.today()
    result = await db.execute(
        select(Checkin).where(
            Checkin.user_id == user.id,
            Checkin.gym_id == gym.id,
            func.date(Checkin.checked_in_at) == today,
            Checkin.status != "flagged",
        )
    )
    if result.scalar_one_or_none():
        raise DuplicateCheckinError()

    # Step 4 — Deduct from wallet and record
    rate = subscription.daily_rate
    subscription.wallet_balance = subscription.wallet_balance - rate
    subscription.visits_used += 1
    subscription.visits_remaining -= 1

    qr_token = uuid.uuid4().hex[:32]

    checkin = Checkin(
        user_id=user.id,
        gym_id=gym.id,
        subscription_id=subscription.id,
        qr_token=qr_token,
        daily_rate_paid=rate,
        plan_tier=plan.tier,
        status="completed",
    )
    db.add(checkin)

    # Step 5 — Check if subscription now exhausted
    if subscription.visits_remaining <= 0:
        subscription.status = "expired"

    await db.flush()
    return checkin


async def list_user_checkins(
    user_id: str, db: AsyncSession, limit: int = 50, offset: int = 0
):
    result = await db.execute(
        select(Checkin)
        .where(Checkin.user_id == user_id)
        .order_by(Checkin.checked_in_at.desc())
        .limit(limit)
        .offset(offset)
    )
    return list(result.scalars().all())


async def get_checkin_by_id(checkin_id: str, db: AsyncSession) -> Checkin:
    checkin = await db.get(Checkin, checkin_id)
    if not checkin:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Checkin not found")
    return checkin
