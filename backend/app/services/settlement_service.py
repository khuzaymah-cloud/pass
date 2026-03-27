from datetime import date
from decimal import Decimal
from typing import List

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.models.gym import Gym
from app.models.checkin import Checkin
from app.models.gym_settlement import GymSettlement
from app.models.country import Country


async def run_monthly_settlement(
    country: Country,
    period_start: date,
    period_end: date,
    db: AsyncSession,
) -> List[GymSettlement]:
    gyms_result = await db.execute(
        select(Gym).where(
            Gym.country_id == country.id,
            Gym.is_active == True,
            Gym.deleted_at.is_(None),
        )
    )
    gyms = gyms_result.scalars().all()
    settlements = []

    for gym in gyms:
        result = await db.execute(
            select(
                func.count(Checkin.id).label("total_visits"),
                func.coalesce(func.sum(Checkin.daily_rate_paid), 0).label("total_payout"),
            ).where(
                Checkin.gym_id == gym.id,
                Checkin.status == "completed",
                func.date(Checkin.checked_in_at) >= period_start,
                func.date(Checkin.checked_in_at) <= period_end,
            )
        )
        row = result.one()
        total_visits = row.total_visits or 0
        total_payout = row.total_payout or Decimal("0")

        if total_visits == 0:
            continue

        settlement = GymSettlement(
            gym_id=gym.id,
            country_id=country.id,
            period_start=period_start,
            period_end=period_end,
            total_visits=total_visits,
            total_payout=total_payout,
            currency_code=country.currency_code,
            status="pending",
        )
        db.add(settlement)
        settlements.append(settlement)

    await db.flush()
    return settlements


async def list_settlements(
    country: Country, db: AsyncSession, gym_id: str = None
) -> List[GymSettlement]:
    q = select(GymSettlement).where(GymSettlement.country_id == country.id)
    if gym_id:
        q = q.where(GymSettlement.gym_id == gym_id)
    q = q.order_by(GymSettlement.period_start.desc())
    result = await db.execute(q)
    return list(result.scalars().all())
