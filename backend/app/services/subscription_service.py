from datetime import datetime, timedelta, timezone
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from fastapi import HTTPException, status

from app.models.subscription import Subscription
from app.models.plan import Plan
from app.models.user import User
from app.models.country import Country


def is_expired(sub: Subscription) -> bool:
    now = datetime.now(timezone.utc)
    return (
        sub.visits_used >= sub.max_visits
        or (sub.expires_at is not None and now > sub.expires_at)
    )


async def create_subscription(
    user: User, plan: Plan, country: Country, db: AsyncSession
) -> Subscription:
    sub = Subscription(
        user_id=user.id,
        plan_id=plan.id,
        country_id=country.id,
        status="pending",
        price_paid=plan.price_local,
        daily_rate=plan.daily_rate,
        max_visits=plan.max_visits,
        validity_days=plan.validity_days,
        visits_used=0,
        visits_remaining=plan.max_visits,
        wallet_balance=plan.price_local,
    )
    db.add(sub)
    await db.flush()
    return sub


async def activate_subscription(sub: Subscription, db: AsyncSession) -> Subscription:
    now = datetime.now(timezone.utc)
    sub.status = "active"
    sub.started_at = now
    sub.expires_at = now + timedelta(days=sub.validity_days)
    sub.wallet_balance = sub.price_paid
    sub.visits_remaining = sub.max_visits
    await db.flush()
    return sub


async def get_active_subscription(user_id: str, db: AsyncSession) -> Optional[Subscription]:
    result = await db.execute(
        select(Subscription).where(
            Subscription.user_id == user_id,
            Subscription.status == "active",
            Subscription.deleted_at.is_(None),
        ).order_by(Subscription.created_at.desc())
    )
    sub = result.scalar_one_or_none()
    if sub and is_expired(sub):
        sub.status = "expired"
        await db.flush()
        return None
    return sub


async def get_subscription_by_id(sub_id: str, db: AsyncSession) -> Subscription:
    sub = await db.get(Subscription, sub_id)
    if not sub or sub.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Subscription not found")
    return sub


async def list_user_subscriptions(user_id: str, db: AsyncSession) -> List[Subscription]:
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == user_id, Subscription.deleted_at.is_(None))
        .order_by(Subscription.created_at.desc())
    )
    return list(result.scalars().all())


async def expire_due_subscriptions(db: AsyncSession) -> int:
    """Daily job: expire all subscriptions past their time or visit limits."""
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(Subscription).where(
            Subscription.status == "active",
            or_(
                Subscription.expires_at < now,
                Subscription.visits_used >= Subscription.max_visits,
            ),
        )
    )
    subs = result.scalars().all()
    count = 0
    for sub in subs:
        sub.status = "expired"
        count += 1
    await db.flush()
    return count
