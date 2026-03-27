import logging
from app.config import settings

logger = logging.getLogger(__name__)


async def send_push_notification(fcm_token: str, title: str, body: str, data: dict = None):
    if not fcm_token:
        return
    if settings.ENVIRONMENT == "development":
        logger.info(f"[PUSH] token={fcm_token[:20]}... title={title}")
        return
    # TODO: firebase_admin integration
