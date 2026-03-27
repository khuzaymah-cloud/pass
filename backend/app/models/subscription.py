import uuid
from sqlalchemy import Column, String, Integer, Boolean, DECIMAL, DateTime, Text, func
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    plan_id = Column(UUID(as_uuid=True), nullable=False)
    country_id = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    price_paid = Column(DECIMAL(12, 3), nullable=False)
    daily_rate = Column(DECIMAL(12, 3), nullable=False)
    max_visits = Column(Integer, nullable=False, default=30)
    validity_days = Column(Integer, nullable=False, default=30)
    visits_used = Column(Integer, nullable=False, default=0)
    visits_remaining = Column(Integer, nullable=False, default=30)
    wallet_balance = Column(DECIMAL(12, 3), nullable=False)
    started_at = Column(DateTime(timezone=True), nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=True)
    auto_renew = Column(Boolean, nullable=False, default=False)
    cancelled_at = Column(DateTime(timezone=True), nullable=True)
    cancel_reason = Column(Text, nullable=True)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
