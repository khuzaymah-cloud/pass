import uuid
import qrcode
import io
import base64


def generate_qr_token() -> str:
    return uuid.uuid4().hex[:32]


def generate_qr_image_base64(data: str) -> str:
    qr = qrcode.QRCode(version=1, box_size=10, border=2)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="#00FF88", back_color="#000000")
    buffer = io.BytesIO()
    img.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode()
