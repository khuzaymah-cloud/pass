from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, get_country
from app.models.user import User
from app.models.country import Country
from app.schemas.auth import (
    SendOTPRequest, SendOTPResponse,
    VerifyOTPRequest, VerifyOTPResponse,
    RefreshTokenRequest, RefreshTokenResponse,
    RegisterRequest, UserBrief,
)
from app.services import auth_service, user_service

router = APIRouter()


@router.post("/send-otp", response_model=SendOTPResponse)
async def send_otp(
    body: SendOTPRequest,
    db: AsyncSession = Depends(get_db),
    country: Country = Depends(get_country),
):
    result = await auth_service.send_otp(body.phone, country, db)
    return result


@router.post("/verify-otp", response_model=VerifyOTPResponse)
async def verify_otp(
    body: VerifyOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await auth_service.verify_otp(body.phone, body.code, db)
    return result


@router.post("/refresh", response_model=RefreshTokenResponse)
async def refresh_token(
    body: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    return await auth_service.refresh_tokens(body.refresh_token, db)


@router.post("/register", response_model=UserBrief)
async def register(
    body: RegisterRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    updated = await user_service.register_user(user, body.model_dump(), db)
    return updated
