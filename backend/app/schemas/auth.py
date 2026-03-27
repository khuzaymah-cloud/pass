from pydantic import BaseModel, ConfigDict
from typing import Optional
from uuid import UUID


class SendOTPRequest(BaseModel):
    phone: str
    country_code: str = "JO"


class SendOTPResponse(BaseModel):
    message: str
    phone: str
    debug_otp: Optional[str] = None


class VerifyOTPRequest(BaseModel):
    phone: str
    code: str


class VerifyOTPResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_new_user: bool
    user: Optional["UserBrief"] = None


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class RefreshTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserBrief(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    phone: str
    full_name: str
    role: str
    country_id: int
    preferred_language: str


class RegisterRequest(BaseModel):
    full_name: str
    email: Optional[str] = None
    gender: Optional[str] = None
    birth_date: Optional[str] = None
