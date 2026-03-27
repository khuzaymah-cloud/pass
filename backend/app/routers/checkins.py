from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.checkin import CheckinOut, CheckinRequest
from app.services import checkin_service, subscription_service, gym_service, plan_service

router = APIRouter()


@router.post("", response_model=CheckinOut)
async def checkin(
    body: CheckinRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    sub = await subscription_service.get_active_subscription(str(user.id), db)
    if not sub:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No active subscription")
    gym = await gym_service.get_gym_by_id(body.gym_id, db)
    plan = await plan_service.get_plan_by_id(str(sub.plan_id), db)
    return await checkin_service.process_checkin(user, gym, sub, plan, db)


@router.get("", response_model=List[CheckinOut])
async def list_checkins(
    limit: int = Query(50, le=100),
    offset: int = 0,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await checkin_service.list_user_checkins(str(user.id), db, limit, offset)


@router.get("/{checkin_id}", response_model=CheckinOut)
async def get_checkin(
    checkin_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await checkin_service.get_checkin_by_id(checkin_id, db)
