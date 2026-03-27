from typing import List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.plan import Plan
from app.models.country import Country


async def list_plans(country: Country, db: AsyncSession) -> List[Plan]:
    result = await db.execute(
        select(Plan)
        .where(Plan.country_id == country.id, Plan.is_active == True)
        .order_by(Plan.sort_order, Plan.price_local)
    )
    return list(result.scalars().all())


async def get_plan_by_id(plan_id: str, db: AsyncSession) -> Plan:
    plan = await db.get(Plan, plan_id)
    if not plan:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plan not found")
    return plan
