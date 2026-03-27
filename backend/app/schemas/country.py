from pydantic import BaseModel, ConfigDict
from typing import Optional, List
from datetime import datetime
from decimal import Decimal


class CountryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    code: str
    name_en: str
    name_ar: str
    currency_code: str
    currency_symbol_en: str
    currency_symbol_ar: str
    vat_rate: Decimal
    phone_prefix: str
    default_lang: str
    is_active: bool
