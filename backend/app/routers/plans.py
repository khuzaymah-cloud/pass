from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_country
from app.models.country import Country
from app.schemas.plan import PlanOut
from app.services import plan_service

router = APIRouter()


@router.get("", response_model=List[PlanOut])
async def list_plans(
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    return await plan_service.list_plans(country, db)


@router.get("/{plan_id}", response_model=PlanOut)
async def get_plan(plan_id: str, db: AsyncSession = Depends(get_db)):
    return await plan_service.get_plan_by_id(plan_id, db)
