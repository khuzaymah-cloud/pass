import uuid
import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import Decimal
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.payment import Payment
from app.models.subscription import Subscription
from app.models.country import Country
from app.services.subscription_service import activate_subscription

logger = logging.getLogger(__name__)


@dataclass
class PaymentInitResult:
    gateway_ref: str
    redirect_url: str
    status: str = "pending"


@dataclass
class WebhookResult:
    gateway_ref: str
    status: str
    amount: Optional[Decimal] = None
    currency: Optional[str] = None


class BaseGateway(ABC):
    @abstractmethod
    async def initiate(
        self, amount: Decimal, currency: str, user_id: str, plan_id: str
    ) -> PaymentInitResult:
        ...

    @abstractmethod
    async def verify_webhook(self, payload: dict) -> WebhookResult:
        ...


class PlaceholderGateway(BaseGateway):
    async def initiate(
        self, amount: Decimal, currency: str, user_id: str, plan_id: str
    ) -> PaymentInitResult:
        ref = f"stub-{uuid.uuid4().hex[:12]}"
        logger.info(
            f"[PAYMENT PLACEHOLDER] Would charge {amount} {currency} for user {user_id}"
        )
        return PaymentInitResult(
            gateway_ref=ref, redirect_url="/payment-stub", status="pending"
        )

    async def verify_webhook(self, payload: dict) -> WebhookResult:
        return WebhookResult(
            gateway_ref=payload.get("gateway_ref", ""),
            status="success",
        )


class ManualGateway(BaseGateway):
    """Admin manually activates — no online payment."""

    async def initiate(
        self, amount: Decimal, currency: str, user_id: str, plan_id: str
    ) -> PaymentInitResult:
        ref = f"manual-{uuid.uuid4().hex[:12]}"
        return PaymentInitResult(
            gateway_ref=ref, redirect_url="/payment-manual", status="pending_manual"
        )

    async def verify_webhook(self, payload: dict) -> WebhookResult:
        return WebhookResult(
            gateway_ref=payload.get("gateway_ref", ""), status="success"
        )


GATEWAY_MAP = {
    "placeholder": PlaceholderGateway,
    "manual": ManualGateway,
    # Future: "myfatoorah": MyFatoorahGateway, "paytabs": PayTabsGateway, etc.
}


def get_gateway(country: Country) -> BaseGateway:
    cls = GATEWAY_MAP.get(country.payment_gateway, PlaceholderGateway)
    return cls()


async def initiate_payment(
    subscription: Subscription,
    country: Country,
    db: AsyncSession,
) -> dict:
    gateway = get_gateway(country)
    vat_rate = country.vat_rate or Decimal("0")
    amount = subscription.price_paid
    vat_amount = amount * vat_rate / Decimal("100")
    total = amount + vat_amount

    result = await gateway.initiate(
        amount=total,
        currency=country.currency_code,
        user_id=str(subscription.user_id),
        plan_id=str(subscription.plan_id),
    )

    payment = Payment(
        subscription_id=subscription.id,
        user_id=subscription.user_id,
        country_id=country.id,
        amount_local=amount,
        currency_code=country.currency_code,
        vat_rate=vat_rate,
        vat_amount=vat_amount,
        total_charged=total,
        gateway=country.payment_gateway,
        gateway_ref=result.gateway_ref,
        status=result.status,
    )
    db.add(payment)
    await db.flush()

    return {
        "payment_id": str(payment.id),
        "redirect_url": result.redirect_url,
        "gateway_ref": result.gateway_ref,
        "status": result.status,
    }


async def handle_webhook(
    gateway_ref: str, country: Country, db: AsyncSession
) -> Payment:
    result = await db.execute(
        select(Payment).where(Payment.gateway_ref == gateway_ref)
    )
    payment = result.scalar_one_or_none()
    if not payment:
        from app.core.exceptions import PaymentNotFoundError
        raise PaymentNotFoundError()

    gateway = get_gateway(country)
    webhook_result = await gateway.verify_webhook({"gateway_ref": gateway_ref})

    payment.status = webhook_result.status
    if webhook_result.status == "success":
        payment.paid_at = datetime.now(timezone.utc)
        sub = await db.get(Subscription, payment.subscription_id)
        if sub and sub.status == "pending":
            await activate_subscription(sub, db)

    await db.flush()
    return payment
