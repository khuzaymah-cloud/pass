import logging

logger = logging.getLogger(__name__)


async def send_push(fcm_token: str, title: str, body: str, data: dict = None):
    """Send FCM push notification. Placeholder until Firebase is configured."""
    if not fcm_token:
        return
    logger.info(f"[PUSH] to={fcm_token[:20]}... title={title} body={body}")
    # TODO: Integrate firebase_admin when FIREBASE_CREDENTIALS_PATH is set
