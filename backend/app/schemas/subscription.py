from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from decimal import Decimal
from uuid import UUID


class SubscriptionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    plan_id: UUID
    country_id: int
    status: str
    price_paid: Decimal
    daily_rate: Decimal
    max_visits: int
    validity_days: int
    visits_used: int
    visits_remaining: int
    wallet_balance: Decimal
    started_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    auto_renew: bool
    created_at: datetime


class SubscriptionCreate(BaseModel):
    plan_id: str
