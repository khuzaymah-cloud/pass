import random
import logging
from datetime import datetime, timedelta, timezone

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.config import settings
from app.core.redis import redis_client
from app.core.security import create_access_token, create_refresh_token, decode_refresh_token
from app.core.exceptions import OTPRateLimitError, OTPLockoutError, OTPInvalidError
from app.models.user import User
from app.models.country import Country

logger = logging.getLogger(__name__)

OTP_PREFIX = "otp:"
OTP_ATTEMPTS_PREFIX = "otp_attempts:"
OTP_RATE_PREFIX = "otp_rate:"
OTP_LOCKOUT_PREFIX = "otp_lockout:"


async def send_otp(phone: str, country: Country, db: AsyncSession) -> dict:
    lockout = await redis_client.get(f"{OTP_LOCKOUT_PREFIX}{phone}")
    if lockout:
        raise OTPLockoutError("Too many failed attempts. Try again later.")

    rate_key = f"{OTP_RATE_PREFIX}{phone}"
    rate_count = await redis_client.get(rate_key)
    if rate_count and int(rate_count) >= settings.OTP_RATE_LIMIT:
        raise OTPRateLimitError("Too many OTP requests. Try again later.")

    code = f"{random.randint(100000, 999999)}"

    await redis_client.setex(f"{OTP_PREFIX}{phone}", settings.OTP_EXPIRY_SECONDS, code)
    await redis_client.delete(f"{OTP_ATTEMPTS_PREFIX}{phone}")

    if not rate_count:
        await redis_client.setex(rate_key, settings.OTP_RATE_WINDOW, 1)
    else:
        await redis_client.incr(rate_key)

    if settings.ENVIRONMENT == "development":
        logger.info(f"[DEBUG OTP] phone={phone} code={code}")
        return {"message": "OTP sent", "phone": phone, "debug_otp": code}

    from app.utils.sms import send_sms
    await send_sms(phone, f"Your GymPass code is: {code}", country)
    return {"message": "OTP sent", "phone": phone}


async def verify_otp(phone: str, code: str, db: AsyncSession) -> dict:
    lockout = await redis_client.get(f"{OTP_LOCKOUT_PREFIX}{phone}")
    if lockout:
        raise OTPLockoutError("Account locked. Try again later.")

    # Debug master OTP
    if settings.ENVIRONMENT == "development" and code == settings.MASTER_OTP:
        pass  # bypass Redis check
    else:
        stored = await redis_client.get(f"{OTP_PREFIX}{phone}")
        if not stored or stored != code:
            attempts_key = f"{OTP_ATTEMPTS_PREFIX}{phone}"
            attempts = await redis_client.incr(attempts_key)
            await redis_client.expire(attempts_key, settings.OTP_EXPIRY_SECONDS)
            if int(attempts) >= settings.OTP_MAX_ATTEMPTS:
                await redis_client.setex(
                    f"{OTP_LOCKOUT_PREFIX}{phone}",
                    settings.OTP_LOCKOUT_SECONDS,
                    "1",
                )
            raise OTPInvalidError("Invalid OTP code")
        await redis_client.delete(f"{OTP_PREFIX}{phone}")

    await redis_client.delete(f"{OTP_ATTEMPTS_PREFIX}{phone}")

    result = await db.execute(select(User).where(User.phone == phone, User.deleted_at.is_(None)))
    user = result.scalar_one_or_none()
    is_new = user is None

    if is_new:
        country = await db.execute(select(Country).where(Country.code == "JO"))
        default_country = country.scalar_one_or_none()
        user = User(
            phone=phone,
            full_name="New User",
            role="member",
            country_id=default_country.id if default_country else 1,
        )
        db.add(user)
        await db.flush()

    access_token = create_access_token(str(user.id), user.role)
    refresh_token = create_refresh_token(str(user.id))

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "is_new_user": is_new,
        "user": user,
    }


async def refresh_tokens(refresh_token_str: str, db: AsyncSession) -> dict:
    payload = decode_refresh_token(refresh_token_str)
    if not payload:
        raise OTPInvalidError("Invalid refresh token")
    user_id = payload.get("sub")
    user = await db.get(User, user_id)
    if not user or not user.is_active:
        raise OTPInvalidError("User not found")
    access_token = create_access_token(str(user.id), user.role)
    return {"access_token": access_token, "token_type": "bearer"}
