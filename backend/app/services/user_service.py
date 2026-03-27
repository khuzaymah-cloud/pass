from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException, status

from app.models.user import User


async def get_user_by_id(user_id: str, db: AsyncSession) -> User:
    user = await db.get(User, user_id)
    if not user or user.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


async def update_user(user: User, data: dict, db: AsyncSession) -> User:
    for key, value in data.items():
        if value is not None and hasattr(user, key):
            setattr(user, key, value)
    await db.flush()
    return user


async def register_user(user: User, data: dict, db: AsyncSession) -> User:
    if data.get("full_name"):
        user.full_name = data["full_name"]
    if data.get("email"):
        existing = await db.execute(
            select(User).where(User.email == data["email"], User.id != user.id)
        )
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already in use")
        user.email = data["email"]
    if data.get("gender"):
        user.gender = data["gender"]
    if data.get("birth_date"):
        user.birth_date = data["birth_date"]
    await db.flush()
    return user
