from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from uuid import UUID


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    phone: str
    email: Optional[str] = None
    full_name: str
    avatar_url: Optional[str] = None
    gender: Optional[str] = None
    birth_date: Optional[str] = None
    role: str
    country_id: int
    preferred_language: str
    theme_preference: str
    is_active: bool
    created_at: datetime


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    gender: Optional[str] = None
    birth_date: Optional[str] = None
    avatar_url: Optional[str] = None
    preferred_language: Optional[str] = None
    theme_preference: Optional[str] = None
    fcm_token: Optional[str] = None
