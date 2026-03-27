"""Initial schema

Revision ID: 001_initial
Revises:
Create Date: 2026-03-27
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID, JSONB

revision: str = "001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # countries
    op.create_table(
        "countries",
        sa.Column("id", sa.Integer, primary_key=True, autoincrement=True),
        sa.Column("code", sa.String(3), unique=True, nullable=False),
        sa.Column("name_en", sa.String(100), nullable=False),
        sa.Column("name_ar", sa.String(100), nullable=False),
        sa.Column("currency_code", sa.String(3), nullable=False),
        sa.Column("currency_symbol_en", sa.String(10), nullable=False),
        sa.Column("currency_symbol_ar", sa.String(10), nullable=False),
        sa.Column("vat_rate", sa.DECIMAL(5, 2), server_default="0.00"),
        sa.Column("payment_gateway", sa.String(20), nullable=False, server_default="placeholder"),
        sa.Column("sms_provider", sa.String(20), nullable=False, server_default="twilio"),
        sa.Column("phone_prefix", sa.String(5), nullable=False),
        sa.Column("default_lang", sa.String(2), server_default="ar"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("launched_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("config", JSONB, server_default="{}"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # cities
    op.create_table(
        "cities",
        sa.Column("id", sa.Integer, primary_key=True, autoincrement=True),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("name_en", sa.String(100), nullable=False),
        sa.Column("name_ar", sa.String(100), nullable=False),
        sa.Column("is_active", sa.Boolean, server_default="true"),
    )

    # users
    op.create_table(
        "users",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("phone", sa.String(20), unique=True, nullable=False),
        sa.Column("email", sa.String(255), unique=True, nullable=True),
        sa.Column("full_name", sa.String(255), nullable=False),
        sa.Column("avatar_url", sa.Text, nullable=True),
        sa.Column("gender", sa.String(10), nullable=True),
        sa.Column("birth_date", sa.Date, nullable=True),
        sa.Column("role", sa.String(20), nullable=False, server_default="member"),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("preferred_language", sa.String(2), server_default="ar"),
        sa.Column("theme_preference", sa.String(10), server_default="system"),
        sa.Column("fcm_token", sa.Text, nullable=True),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # gym_partners
    op.create_table(
        "gym_partners",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id"), unique=True, nullable=False),
        sa.Column("business_name_en", sa.String(255), nullable=False),
        sa.Column("business_name_ar", sa.String(255), nullable=True),
        sa.Column("cr_number", sa.String(100), nullable=True),
        sa.Column("bank_iban", sa.String(34), nullable=True),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("is_verified", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # gyms
    op.create_table(
        "gyms",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("partner_id", UUID(as_uuid=True), sa.ForeignKey("gym_partners.id"), nullable=True),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("name_en", sa.String(255), nullable=False),
        sa.Column("name_ar", sa.String(255), nullable=True),
        sa.Column("description_en", sa.Text, nullable=True),
        sa.Column("description_ar", sa.Text, nullable=True),
        sa.Column("tier", sa.String(20), nullable=False, server_default="standard"),
        sa.Column("address", sa.String(500), nullable=False),
        sa.Column("city_id", sa.Integer, sa.ForeignKey("cities.id"), nullable=True),
        sa.Column("lat", sa.DECIMAL(10, 7), nullable=False),
        sa.Column("lng", sa.DECIMAL(10, 7), nullable=False),
        sa.Column("phone", sa.String(20), nullable=True),
        sa.Column("logo_url", sa.Text, nullable=True),
        sa.Column("cover_url", sa.Text, nullable=True),
        sa.Column("photos", JSONB, server_default="[]"),
        sa.Column("opening_hours", JSONB, nullable=False),
        sa.Column("amenities", JSONB, server_default="[]"),
        sa.Column("categories", JSONB, server_default="[]"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("is_featured", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("rating", sa.DECIMAL(2, 1), server_default="0.0"),
        sa.Column("total_reviews", sa.Integer, server_default="0"),
        sa.Column("max_daily_visits", sa.Integer, server_default="1"),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # plans
    op.create_table(
        "plans",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("tier", sa.String(20), nullable=False),
        sa.Column("name_en", sa.String(100), nullable=False),
        sa.Column("name_ar", sa.String(100), nullable=False),
        sa.Column("price_local", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("daily_rate", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("max_visits", sa.Integer, nullable=False, server_default="30"),
        sa.Column("validity_days", sa.Integer, nullable=False, server_default="30"),
        sa.Column("gym_tier_access", sa.String(20), nullable=False),
        sa.Column("features_en", JSONB, server_default="[]"),
        sa.Column("features_ar", JSONB, server_default="[]"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default="true"),
        sa.Column("sort_order", sa.Integer, server_default="0"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # subscriptions
    op.create_table(
        "subscriptions",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("plan_id", UUID(as_uuid=True), sa.ForeignKey("plans.id"), nullable=False),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("price_paid", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("daily_rate", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("max_visits", sa.Integer, nullable=False, server_default="30"),
        sa.Column("validity_days", sa.Integer, nullable=False, server_default="30"),
        sa.Column("visits_used", sa.Integer, nullable=False, server_default="0"),
        sa.Column("visits_remaining", sa.Integer, nullable=False, server_default="30"),
        sa.Column("wallet_balance", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("auto_renew", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("cancelled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cancel_reason", sa.Text, nullable=True),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # checkins
    op.create_table(
        "checkins",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("gym_id", UUID(as_uuid=True), sa.ForeignKey("gyms.id"), nullable=False),
        sa.Column("subscription_id", UUID(as_uuid=True), sa.ForeignKey("subscriptions.id"), nullable=False),
        sa.Column("qr_token", sa.String(64), unique=True, nullable=False),
        sa.Column("checked_in_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("checked_out_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="active"),
        sa.Column("daily_rate_paid", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("plan_tier", sa.String(20), nullable=False),
        sa.Column("device_info", JSONB, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # payments
    op.create_table(
        "payments",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("subscription_id", UUID(as_uuid=True), sa.ForeignKey("subscriptions.id"), nullable=False),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("amount_local", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("currency_code", sa.String(3), nullable=False),
        sa.Column("vat_rate", sa.DECIMAL(5, 2), nullable=False, server_default="0"),
        sa.Column("vat_amount", sa.DECIMAL(12, 3), nullable=False, server_default="0"),
        sa.Column("total_charged", sa.DECIMAL(12, 3), nullable=False),
        sa.Column("gateway", sa.String(20), nullable=False),
        sa.Column("gateway_ref", sa.String(255), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("paid_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata", JSONB, server_default="{}"),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # gym_settlements
    op.create_table(
        "gym_settlements",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("gym_id", UUID(as_uuid=True), sa.ForeignKey("gyms.id"), nullable=False),
        sa.Column("country_id", sa.Integer, sa.ForeignKey("countries.id"), nullable=False),
        sa.Column("period_start", sa.Date, nullable=False),
        sa.Column("period_end", sa.Date, nullable=False),
        sa.Column("total_visits", sa.Integer, nullable=False, server_default="0"),
        sa.Column("total_payout", sa.DECIMAL(12, 3), nullable=False, server_default="0"),
        sa.Column("currency_code", sa.String(3), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("paid_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("notes", sa.Text, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # otp_codes
    op.create_table(
        "otp_codes",
        sa.Column("id", UUID(as_uuid=True), primary_key=True, server_default=sa.text("gen_random_uuid()")),
        sa.Column("phone", sa.String(20), nullable=False),
        sa.Column("code", sa.String(6), nullable=False),
        sa.Column("purpose", sa.String(20), server_default="login"),
        sa.Column("attempts", sa.Integer, nullable=False, server_default="0"),
        sa.Column("used", sa.Boolean, nullable=False, server_default="false"),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # Required indexes
    op.create_index("ix_gyms_country_active", "gyms", ["country_id", "is_active"])
    op.create_index("ix_plans_country_active", "plans", ["country_id", "is_active"])
    op.create_index("ix_checkins_user_date", "checkins", ["user_id", "checked_in_at"])
    op.create_index("ix_checkins_user_gym_date", "checkins", ["user_id", "gym_id", "checked_in_at"])
    op.create_index("ix_subs_status_expires", "subscriptions", ["status", "expires_at"])
    op.create_index("ix_subs_status_visits", "subscriptions", ["status", "visits_used"])
    op.create_index("ix_otp_phone_expires", "otp_codes", ["phone", "expires_at"])
    op.create_index("ix_settlements_gym_period", "gym_settlements", ["gym_id", "period_start"])

    # Seed 12 ME countries
    op.execute("""
        INSERT INTO countries (code, name_en, name_ar, currency_code, currency_symbol_en, currency_symbol_ar, vat_rate, payment_gateway, sms_provider, phone_prefix, is_active) VALUES
        ('JO', 'Jordan',        'الأردن',         'JOD', 'JD',  'د.أ',  0.00,  'placeholder', 'jawwalsms', '+962', true),
        ('SA', 'Saudi Arabia',  'السعودية',       'SAR', 'SAR', 'ر.س',  15.00, 'placeholder', 'unifonic',  '+966', false),
        ('AE', 'UAE',           'الإمارات',       'AED', 'AED', 'د.إ',  5.00,  'placeholder', 'twilio',    '+971', false),
        ('EG', 'Egypt',         'مصر',            'EGP', 'EGP', 'ج.م',  14.00, 'placeholder', 'twilio',    '+20',  false),
        ('KW', 'Kuwait',        'الكويت',         'KWD', 'KWD', 'د.ك',  0.00,  'placeholder', 'unifonic',  '+965', false),
        ('BH', 'Bahrain',       'البحرين',        'BHD', 'BHD', 'د.ب',  10.00, 'placeholder', 'unifonic',  '+973', false),
        ('QA', 'Qatar',         'قطر',            'QAR', 'QAR', 'ر.ق',  0.00,  'placeholder', 'unifonic',  '+974', false),
        ('OM', 'Oman',          'عمان',           'OMR', 'OMR', 'ر.ع',  5.00,  'placeholder', 'unifonic',  '+968', false),
        ('IQ', 'Iraq',          'العراق',         'IQD', 'IQD', 'د.ع',  0.00,  'placeholder', 'twilio',    '+964', false),
        ('SY', 'Syria',         'سوريا',          'SYP', 'SYP', 'ل.س',  0.00,  'manual',      'twilio',    '+963', false),
        ('LB', 'Lebanon',       'لبنان',          'LBP', 'LBP', 'ل.ل',  0.00,  'placeholder', 'twilio',    '+961', false),
        ('PS', 'Palestine',     'فلسطين',         'ILS', 'ILS', '₪',    0.00,  'manual',      'jawwalsms', '+970', false);
    """)

    # Seed Jordan plans
    op.execute("""
        INSERT INTO plans (country_id, tier, name_en, name_ar, price_local, daily_rate, max_visits, validity_days, gym_tier_access, sort_order, features_en, features_ar) VALUES
        (1, 'silver',   'Silver',   'فضي',   25.000, 0.833, 30, 30, 'standard', 1,
         '["Access to standard gyms","30 visits per month","QR code check-in"]',
         '["دخول الأندية العادية","30 زيارة شهرياً","تسجيل دخول برمز QR"]'),
        (1, 'gold',     'Gold',     'ذهبي',   40.000, 1.333, 30, 30, 'gold',     2,
         '["Access to standard + gold gyms","30 visits per month","QR code check-in","Priority support"]',
         '["دخول الأندية العادية والذهبية","30 زيارة شهرياً","تسجيل دخول برمز QR","دعم أولوية"]'),
        (1, 'platinum', 'Platinum', 'بلاتيني', 60.000, 2.000, 30, 30, 'platinum',  3,
         '["Access up to platinum gyms","30 visits per month","QR code check-in","Priority support","Guest pass 1x/month"]',
         '["دخول حتى الأندية البلاتينية","30 زيارة شهرياً","تسجيل دخول برمز QR","دعم أولوية","تذكرة ضيف 1 شهرياً"]'),
        (1, 'diamond',  'Diamond',  'ماسي',   90.000, 3.000, 30, 30, 'diamond',   4,
         '["Access to ALL gyms","30 visits per month","QR code check-in","VIP support","Guest pass 2x/month","Exclusive events"]',
         '["دخول جميع الأندية","30 زيارة شهرياً","تسجيل دخول برمز QR","دعم VIP","تذكرة ضيف 2 شهرياً","فعاليات حصرية"]');
    """)

    # Seed Amman cities
    op.execute("""
        INSERT INTO cities (country_id, name_en, name_ar) VALUES
        (1, 'Amman',   'عمّان'),
        (1, 'Irbid',   'إربد'),
        (1, 'Zarqa',   'الزرقاء'),
        (1, 'Aqaba',   'العقبة'),
        (1, 'Madaba',  'مادبا');
    """)

    # Seed sample gyms in Amman
    op.execute("""
        INSERT INTO gyms (country_id, name_en, name_ar, tier, address, city_id, lat, lng, opening_hours, amenities, categories, is_active, is_featured) VALUES
        (1, 'FitZone Abdoun',      'فت زون عبدون',      'standard', 'Abdoun, Amman',         1, 31.9539, 35.8830, '{"mon":{"open":"06:00","close":"23:00"},"tue":{"open":"06:00","close":"23:00"},"wed":{"open":"06:00","close":"23:00"},"thu":{"open":"06:00","close":"23:00"},"fri":{"open":"08:00","close":"22:00"},"sat":{"open":"06:00","close":"23:00"},"sun":{"open":"06:00","close":"23:00"}}', '["WiFi","Showers","Lockers","Parking"]',       '["Weights","Cardio"]',           true, true),
        (1, 'PowerHouse Gym',      'باور هاوس جيم',     'gold',     'Sweifieh, Amman',       1, 31.9574, 35.8626, '{"mon":{"open":"05:00","close":"00:00"},"tue":{"open":"05:00","close":"00:00"},"wed":{"open":"05:00","close":"00:00"},"thu":{"open":"05:00","close":"00:00"},"fri":{"open":"07:00","close":"23:00"},"sat":{"open":"05:00","close":"00:00"},"sun":{"open":"05:00","close":"00:00"}}', '["WiFi","Showers","Lockers","Pool","Sauna"]',   '["Weights","Cardio","CrossFit"]', true, true),
        (1, 'EliteBody Studio',    'إليت بودي ستوديو',  'platinum', 'Shmeisani, Amman',      1, 31.9722, 35.9018, '{"mon":{"open":"06:00","close":"22:00"},"tue":{"open":"06:00","close":"22:00"},"wed":{"open":"06:00","close":"22:00"},"thu":{"open":"06:00","close":"22:00"},"fri":{"open":"09:00","close":"21:00"},"sat":{"open":"06:00","close":"22:00"},"sun":{"open":"06:00","close":"22:00"}}', '["WiFi","Showers","Lockers","Spa","Sauna"]',    '["Weights","Yoga","Pilates"]',    true, false),
        (1, 'Royal Fitness Club',  'رويال فتنس كلوب',   'diamond',  'Dabouq, Amman',         1, 31.9818, 35.8410, '{"mon":{"open":"05:00","close":"23:00"},"tue":{"open":"05:00","close":"23:00"},"wed":{"open":"05:00","close":"23:00"},"thu":{"open":"05:00","close":"23:00"},"fri":{"open":"07:00","close":"22:00"},"sat":{"open":"05:00","close":"23:00"},"sun":{"open":"05:00","close":"23:00"}}', '["WiFi","Showers","Lockers","Pool","Spa","Sauna","Juice Bar"]', '["Weights","Cardio","CrossFit","Boxing","Yoga"]', true, true),
        (1, 'IronWorks Gym',       'آيرن ووركس جيم',    'standard', 'Jubeiha, Amman',        1, 32.0172, 35.8710, '{"mon":{"open":"06:00","close":"23:00"},"tue":{"open":"06:00","close":"23:00"},"wed":{"open":"06:00","close":"23:00"},"thu":{"open":"06:00","close":"23:00"},"fri":{"open":"08:00","close":"22:00"},"sat":{"open":"06:00","close":"23:00"},"sun":{"open":"06:00","close":"23:00"}}', '["Showers","Lockers","Parking"]', '["Weights","Cardio"]',            true, false);
    """)


def downgrade() -> None:
    op.drop_table("otp_codes")
    op.drop_table("gym_settlements")
    op.drop_table("payments")
    op.drop_table("checkins")
    op.drop_table("subscriptions")
    op.drop_table("plans")
    op.drop_table("gyms")
    op.drop_table("gym_partners")
    op.drop_table("users")
    op.drop_table("cities")
    op.drop_table("countries")
