import logging
from app.config import settings
from app.models.country import Country

logger = logging.getLogger(__name__)

SMS_PROVIDER_MAP = {
    "jawwalsms": "_send_jawwalsms",
    "unifonic": "_send_unifonic",
    "twilio": "_send_twilio",
}


async def send_sms(phone: str, message: str, country: Country):
    provider = country.sms_provider
    if settings.ENVIRONMENT == "development":
        logger.info(f"[SMS {provider}] to={phone} msg={message}")
        return

    handler = SMS_PROVIDER_MAP.get(provider, "_send_twilio")
    await globals()[handler](phone, message)


async def _send_jawwalsms(phone: str, message: str):
    import httpx
    async with httpx.AsyncClient() as client:
        await client.post(
            "https://api.jawwalsms.net/api/v2/send",
            json={"to": phone, "message": message, "sender": settings.JAWWALSMS_SENDER},
            headers={"Authorization": f"Bearer {settings.JAWWALSMS_API_KEY}"},
        )


async def _send_unifonic(phone: str, message: str):
    import httpx
    async with httpx.AsyncClient() as client:
        await client.post(
            "https://el.cloud.unifonic.com/rest/SMS/messages",
            data={
                "AppSid": settings.UNIFONIC_APP_SID,
                "Recipient": phone,
                "Body": message,
                "SenderID": settings.UNIFONIC_SENDER,
            },
        )


async def _send_twilio(phone: str, message: str):
    from twilio.rest import Client
    client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
    client.messages.create(
        body=message, from_=settings.TWILIO_FROM_NUMBER, to=phone
    )
