from sqlalchemy import Column, Integer, String, Boolean
from app.database import Base


class City(Base):
    __tablename__ = "cities"

    id = Column(Integer, primary_key=True, autoincrement=True)
    country_id = Column(Integer, nullable=False)
    name_en = Column(String(100), nullable=False)
    name_ar = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
