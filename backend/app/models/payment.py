import uuid
from sqlalchemy import Column, String, Integer, DECIMAL, DateTime, Text, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base


class Payment(Base):
    __tablename__ = "payments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    subscription_id = Column(UUID(as_uuid=True), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    country_id = Column(Integer, nullable=False)
    amount_local = Column(DECIMAL(12, 3), nullable=False)
    currency_code = Column(String(3), nullable=False)
    vat_rate = Column(DECIMAL(5, 2), nullable=False, default=0)
    vat_amount = Column(DECIMAL(12, 3), nullable=False, default=0)
    total_charged = Column(DECIMAL(12, 3), nullable=False)
    gateway = Column(String(20), nullable=False)
    gateway_ref = Column(String(255), nullable=True)
    status = Column(String(20), nullable=False, default="pending")
    paid_at = Column(DateTime(timezone=True), nullable=True)
    payment_metadata = Column("metadata", JSONB, default={})
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
