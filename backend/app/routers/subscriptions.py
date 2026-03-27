from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, get_country
from app.models.user import User
from app.models.country import Country
from app.schemas.subscription import SubscriptionOut, SubscriptionCreate
from app.services import subscription_service, plan_service

router = APIRouter()


@router.post("", response_model=SubscriptionOut)
async def create_subscription(
    body: SubscriptionCreate,
    user: User = Depends(get_current_user),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    plan = await plan_service.get_plan_by_id(body.plan_id, db)
    return await subscription_service.create_subscription(user, plan, country, db)


@router.get("/active", response_model=SubscriptionOut)
async def get_active(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    sub = await subscription_service.get_active_subscription(str(user.id), db)
    if not sub:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active subscription")
    return sub


@router.get("", response_model=List[SubscriptionOut])
async def list_subscriptions(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await subscription_service.list_user_subscriptions(str(user.id), db)


@router.get("/{sub_id}", response_model=SubscriptionOut)
async def get_subscription(
    sub_id: str,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await subscription_service.get_subscription_by_id(sub_id, db)
