import uuid
from sqlalchemy import Column, String, Integer, Boolean, DECIMAL, DateTime, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base


class Plan(Base):
    __tablename__ = "plans"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    country_id = Column(Integer, nullable=False)
    tier = Column(String(20), nullable=False)
    name_en = Column(String(100), nullable=False)
    name_ar = Column(String(100), nullable=False)
    price_local = Column(DECIMAL(12, 3), nullable=False)
    daily_rate = Column(DECIMAL(12, 3), nullable=False)
    max_visits = Column(Integer, nullable=False, default=30)
    validity_days = Column(Integer, nullable=False, default=30)
    duration_months = Column(Integer, nullable=False, default=1)
    gym_tier_access = Column(String(20), nullable=False)
    features_en = Column(JSONB, default=[])
    features_ar = Column(JSONB, default=[])
    is_active = Column(Boolean, nullable=False, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
