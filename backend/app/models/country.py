from sqlalchemy import Column, Integer, String, Boolean, DECIMAL, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from app.database import Base


class Country(Base):
    __tablename__ = "countries"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(3), unique=True, nullable=False)
    name_en = Column(String(100), nullable=False)
    name_ar = Column(String(100), nullable=False)
    currency_code = Column(String(3), nullable=False)
    currency_symbol_en = Column(String(10), nullable=False)
    currency_symbol_ar = Column(String(10), nullable=False)
    vat_rate = Column(DECIMAL(5, 2), default=0.00)
    payment_gateway = Column(String(20), nullable=False, default="placeholder")
    sms_provider = Column(String(20), nullable=False, default="twilio")
    phone_prefix = Column(String(5), nullable=False)
    default_lang = Column(String(2), default="ar")
    is_active = Column(Boolean, nullable=False, default=False)
    launched_at = Column(DateTime(timezone=True), nullable=True)
    config = Column(JSONB, default={})
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
