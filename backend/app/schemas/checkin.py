from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from decimal import Decimal
from uuid import UUID


class CheckinOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    gym_id: UUID
    subscription_id: UUID
    qr_token: str
    checked_in_at: datetime
    checked_out_at: Optional[datetime] = None
    status: str
    daily_rate_paid: Decimal
    plan_tier: str


class CheckinRequest(BaseModel):
    gym_id: str
    qr_token: Optional[str] = None
