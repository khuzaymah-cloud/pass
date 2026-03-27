from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_country, get_current_user, require_gym_partner
from app.models.country import Country
from app.models.user import User
from app.schemas.gym import GymOut, GymCreate, GymUpdate
from app.services import gym_service

router = APIRouter()


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
