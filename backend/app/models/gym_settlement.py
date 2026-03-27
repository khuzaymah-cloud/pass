import uuid
from sqlalchemy import Column, String, Integer, DECIMAL, DateTime, Date, Text, func
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class GymSettlement(Base):
    __tablename__ = "gym_settlements"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    gym_id = Column(UUID(as_uuid=True), nullable=False)
    country_id = Column(Integer, nullable=False)
    period_start = Column(Date, nullable=False)
    period_end = Column(Date, nullable=False)
    total_visits = Column(Integer, nullable=False, default=0)
    total_payout = Column(DECIMAL(12, 3), nullable=False, default=0)
    currency_code = Column(String(3), nullable=False)
    status = Column(String(20), nullable=False, default="pending")
    paid_at = Column(DateTime(timezone=True), nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
