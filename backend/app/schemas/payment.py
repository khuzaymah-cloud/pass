from pydantic import BaseModel, ConfigDict
from typing import Optional, Any
from datetime import datetime
from decimal import Decimal
from uuid import UUID


class PaymentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    subscription_id: UUID
    user_id: UUID
    amount_local: Decimal
    currency_code: str
    vat_rate: Decimal
    vat_amount: Decimal
    total_charged: Decimal
    gateway: str
    gateway_ref: Optional[str] = None
    status: str
    paid_at: Optional[datetime] = None
    created_at: datetime


class PaymentInitRequest(BaseModel):
    subscription_id: str


class PaymentInitResponse(BaseModel):
    payment_id: str
    redirect_url: str
    gateway_ref: str
    status: str


class WebhookPayload(BaseModel):
    gateway_ref: str
    status: str = "success"
    metadata: Optional[Any] = None
