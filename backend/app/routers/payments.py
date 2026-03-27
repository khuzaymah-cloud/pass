from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, get_country
from app.models.user import User
from app.models.country import Country
from app.schemas.payment import PaymentInitRequest, PaymentInitResponse, PaymentOut, WebhookPayload
from app.services import payment_service, subscription_service

router = APIRouter()


@router.post("/initiate", response_model=PaymentInitResponse)
async def initiate_payment(
    body: PaymentInitRequest,
    user: User = Depends(get_current_user),
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    sub = await subscription_service.get_subscription_by_id(body.subscription_id, db)
    return await payment_service.initiate_payment(sub, country, db)


@router.post("/webhook/{gateway}")
async def payment_webhook(
    gateway: str,
    body: WebhookPayload,
    country: Country = Depends(get_country),
    db: AsyncSession = Depends(get_db),
):
    payment = await payment_service.handle_webhook(body.gateway_ref, country, db)
    return {"status": payment.status, "payment_id": str(payment.id)}
