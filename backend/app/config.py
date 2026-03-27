from pydantic_settings import BaseSettings
from typing import List
import json


class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    SECRET_KEY: str = "change-me"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    DATABASE_URL: str = "postgresql+asyncpg://onepass:onepass_secret@db:5432/onepass_db"
    DATABASE_URL_SYNC: str = "postgresql://onepass:onepass_secret@db:5432/onepass_db"
    REDIS_URL: str = "redis://redis:6379/0"

    JAWWALSMS_API_KEY: str = ""
    JAWWALSMS_SENDER: str = "1Pass"
    UNIFONIC_APP_SID: str = ""
    UNIFONIC_SENDER: str = "1Pass"
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_FROM_NUMBER: str = ""

    FIREBASE_CREDENTIALS_PATH: str = ""
    GOOGLE_MAPS_API_KEY: str = ""

    MASTER_OTP: str = "123456"
    OTP_EXPIRY_SECONDS: int = 300
    OTP_MAX_ATTEMPTS: int = 3
    OTP_LOCKOUT_SECONDS: int = 900
    OTP_RATE_LIMIT: int = 3
    OTP_RATE_WINDOW: int = 600

    CORS_ORIGINS: str = '["http://localhost:3000","http://localhost:8080"]'

    @property
    def cors_origins_list(self) -> List[str]:
        return json.loads(self.CORS_ORIGINS)

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
