from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.plan import Plan
from app.models.country import Country


async def list_plans(country: Country, db: AsyncSession, duration_months: Optional[int] = None) -> List[Plan]:
    q = select(Plan).where(Plan.country_id == country.id, Plan.is_active == True)
    if duration_months:
        q = q.where(Plan.duration_months == duration_months)
    q = q.order_by(Plan.sort_order, Plan.price_local)
    result = await db.execute(q)
    return list(result.scalars().all())


async def get_plan_by_id(plan_id: str, db: AsyncSession) -> Plan:
    plan = await db.get(Plan, plan_id)
    if not plan:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plan not found")
    return plan
