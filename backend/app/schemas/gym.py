from pydantic import BaseModel, ConfigDict
from typing import Optional, List, Any
from datetime import datetime
from decimal import Decimal
from uuid import UUID


class GymOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name_en: str
    name_ar: Optional[str] = None
    description_en: Optional[str] = None
    description_ar: Optional[str] = None
    tier: str
    address: str
    lat: Decimal
    lng: Decimal
    phone: Optional[str] = None
    logo_url: Optional[str] = None
    cover_url: Optional[str] = None
    photos: Optional[List[Any]] = []
    opening_hours: Any = {}
    amenities: Optional[List[str]] = []
    categories: Optional[List[str]] = []
    is_active: bool
    is_featured: bool
    rating: Decimal
    total_reviews: int
    country_id: int


class GymCreate(BaseModel):
    name_en: str
    name_ar: Optional[str] = None
    description_en: Optional[str] = None
    description_ar: Optional[str] = None
    tier: str = "standard"
    address: str
    city_id: Optional[int] = None
    lat: Decimal
    lng: Decimal
    phone: Optional[str] = None
    logo_url: Optional[str] = None
    cover_url: Optional[str] = None
    opening_hours: Any = {}
    amenities: Optional[List[str]] = []
    categories: Optional[List[str]] = []


class GymUpdate(BaseModel):
    name_en: Optional[str] = None
    name_ar: Optional[str] = None
    description_en: Optional[str] = None
    description_ar: Optional[str] = None
    tier: Optional[str] = None
    address: Optional[str] = None
    lat: Optional[Decimal] = None
    lng: Optional[Decimal] = None
    phone: Optional[str] = None
    logo_url: Optional[str] = None
    cover_url: Optional[str] = None
    opening_hours: Optional[Any] = None
    amenities: Optional[List[str]] = None
    categories: Optional[List[str]] = None
    is_active: Optional[bool] = None
    is_featured: Optional[bool] = None
