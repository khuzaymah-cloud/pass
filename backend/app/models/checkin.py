import uuid
from sqlalchemy import Column, String, DECIMAL, DateTime, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base


class Checkin(Base):
    __tablename__ = "checkins"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    gym_id = Column(UUID(as_uuid=True), nullable=False)
    subscription_id = Column(UUID(as_uuid=True), nullable=False)
    qr_token = Column(String(64), unique=True, nullable=False)
    checked_in_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    checked_out_at = Column(DateTime(timezone=True), nullable=True)
    status = Column(String(20), nullable=False, default="active")
    daily_rate_paid = Column(DECIMAL(12, 3), nullable=False)
    plan_tier = Column(String(20), nullable=False)
    device_info = Column(JSONB, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
