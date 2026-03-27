import uuid
from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, func
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class GymPartner(Base):
    __tablename__ = "gym_partners"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), unique=True, nullable=False)
    business_name_en = Column(String(255), nullable=False)
    business_name_ar = Column(String(255), nullable=True)
    cr_number = Column(String(100), nullable=True)
    bank_iban = Column(String(34), nullable=True)
    country_id = Column(Integer, nullable=False)
    is_verified = Column(Boolean, nullable=False, default=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
