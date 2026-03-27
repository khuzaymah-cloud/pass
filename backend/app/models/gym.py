import uuid
from sqlalchemy import Column, String, Integer, Boolean, DECIMAL, DateTime, Text, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.database import Base


class Gym(Base):
    __tablename__ = "gyms"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    partner_id = Column(UUID(as_uuid=True), nullable=True)
    country_id = Column(Integer, nullable=False)
    name_en = Column(String(255), nullable=False)
    name_ar = Column(String(255), nullable=True)
    description_en = Column(Text, nullable=True)
    description_ar = Column(Text, nullable=True)
    tier = Column(String(20), nullable=False, default="standard")
    address = Column(String(500), nullable=False)
    city_id = Column(Integer, nullable=True)
    lat = Column(DECIMAL(10, 7), nullable=False)
    lng = Column(DECIMAL(10, 7), nullable=False)
    phone = Column(String(20), nullable=True)
    logo_url = Column(Text, nullable=True)
    cover_url = Column(Text, nullable=True)
    photos = Column(JSONB, default=[])
    opening_hours = Column(JSONB, nullable=False)
    amenities = Column(JSONB, default=[])
    categories = Column(JSONB, default=[])
    is_active = Column(Boolean, nullable=False, default=False)
    is_featured = Column(Boolean, nullable=False, default=False)
    rating = Column(DECIMAL(2, 1), default=0.0)
    total_reviews = Column(Integer, default=0)
    max_daily_visits = Column(Integer, default=1)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
