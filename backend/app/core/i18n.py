TRANSLATIONS = {
    "en": {
        "subscription_active": "Your {plan} plan is active! {visits} visits await.",
        "subscription_expired": "Your plan has expired. Renew now.",
        "visits_exhausted": "You've used all {max} visits! Renew to keep going.",
        "checkin_success": "Checked in at {gym}! Visit #{visit_number}.",
        "checkin_duplicate": "Already checked in at this gym today.",
        "tier_blocked": "Your {plan} plan does not include {gym_tier} gyms.",
        "otp_sent": "OTP sent to {phone}.",
        "otp_invalid": "Invalid OTP code.",
        "otp_locked": "Too many attempts. Try again in {minutes} minutes.",
        "otp_rate_limited": "Too many OTP requests. Try again later.",
        "payment_placeholder": "Would charge {amount} {currency} for user {user_id}.",
        "settlement_created": "Settlement for {gym} created: {amount} {currency}.",
        "welcome": "Welcome to GymPass!",
    },
    "ar": {
        "subscription_active": "خطة {plan} الخاصة بك مفعّلة! {visits} زيارة بانتظارك.",
        "subscription_expired": "انتهت خطتك. جدد الآن.",
        "visits_exhausted": "استخدمت جميع الـ {max} زيارة! جدد للاستمرار.",
        "checkin_success": "تم تسجيل الدخول في {gym}! الزيارة رقم #{visit_number}.",
        "checkin_duplicate": "سبق وسجلت دخولك في هذا النادي اليوم.",
        "tier_blocked": "خطة {plan} الخاصة بك لا تشمل أندية {gym_tier}.",
        "otp_sent": "تم إرسال رمز التحقق إلى {phone}.",
        "otp_invalid": "رمز التحقق غير صحيح.",
        "otp_locked": "محاولات كثيرة. حاول مجدداً بعد {minutes} دقائق.",
        "otp_rate_limited": "طلبات كثيرة. حاول مجدداً لاحقاً.",
        "payment_placeholder": "سيتم خصم {amount} {currency} للمستخدم {user_id}.",
        "settlement_created": "تمت تسوية {gym}: {amount} {currency}.",
        "welcome": "مرحباً بك في GymPass!",
    },
}


def t(key: str, lang: str = "en", **kwargs) -> str:
    text = TRANSLATIONS.get(lang, TRANSLATIONS["en"]).get(key, key)
    try:
        return text.format(**kwargs)
    except KeyError:
        return text
