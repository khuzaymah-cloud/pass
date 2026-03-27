from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Any
from decimal import Decimal
from uuid import UUID


class PlanOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    country_id: int
    tier: str
    name_en: str
    name_ar: str
    price_local: Decimal
    daily_rate: Decimal
    max_visits: int
    validity_days: int
    gym_tier_access: str
    features_en: Optional[List[Any]] = []
    features_ar: Optional[List[Any]] = []
    is_active: bool
    sort_order: int
