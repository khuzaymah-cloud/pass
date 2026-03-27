from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.models.gym import Gym
from app.models.country import Country


async def list_gyms(
    country: Country,
    db: AsyncSession,
    tier: Optional[str] = None,
    is_featured: Optional[bool] = None,
    search: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
) -> List[Gym]:
    q = select(Gym).where(
        Gym.country_id == country.id,
        Gym.is_active == True,
        Gym.deleted_at.is_(None),
    )
    if tier:
        q = q.where(Gym.tier == tier)
    if is_featured is not None:
        q = q.where(Gym.is_featured == is_featured)
    if search:
        q = q.where(Gym.name_en.ilike(f"%{search}%"))
    q = q.order_by(Gym.is_featured.desc(), Gym.rating.desc()).limit(limit).offset(offset)
    result = await db.execute(q)
    return list(result.scalars().all())


async def get_gym_by_id(gym_id: str, db: AsyncSession) -> Gym:
    gym = await db.get(Gym, gym_id)
    if not gym or gym.deleted_at is not None:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Gym not found")
    return gym


async def create_gym(data: dict, country: Country, partner_id: Optional[str], db: AsyncSession) -> Gym:
    gym = Gym(
        partner_id=partner_id,
        country_id=country.id,
        **data,
    )
    db.add(gym)
    await db.flush()
    return gym


async def update_gym(gym: Gym, data: dict, db: AsyncSession) -> Gym:
    for key, value in data.items():
        if value is not None and hasattr(gym, key):
            setattr(gym, key, value)
    await db.flush()
    return gym
