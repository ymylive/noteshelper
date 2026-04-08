import base64
import io
import imghdr

from PIL import Image

MAX_DIMENSION = 2048

MIME_MAP = {
    "jpeg": "image/jpeg",
    "png": "image/png",
    "gif": "image/gif",
    "webp": "image/webp",
}


def prepare_image(file_bytes: bytes) -> tuple[str, str]:
    """Resize an image to fit within MAX_DIMENSION and return base64 + MIME type.

    Args:
        file_bytes: Raw bytes of the uploaded image file.

    Returns:
        A tuple of (base64_encoded_string, mime_type).

    Raises:
        ValueError: If the image format is not supported.
    """
    image = Image.open(io.BytesIO(file_bytes))

    # Determine format
    fmt = (image.format or "").lower()
    if fmt == "jpg":
        fmt = "jpeg"
    if fmt not in MIME_MAP:
        # Fallback detection
        detected = imghdr.what(None, h=file_bytes)
        if detected and detected in MIME_MAP:
            fmt = detected
        else:
            raise ValueError(f"Unsupported image format: {fmt or 'unknown'}")

    mime_type = MIME_MAP[fmt]

    # Resize if any dimension exceeds the max
    width, height = image.size
    if width > MAX_DIMENSION or height > MAX_DIMENSION:
        ratio = min(MAX_DIMENSION / width, MAX_DIMENSION / height)
        new_size = (int(width * ratio), int(height * ratio))
        image = image.resize(new_size, Image.LANCZOS)

    # Convert RGBA to RGB for JPEG output
    save_format = fmt.upper()
    if save_format == "JPEG" and image.mode in ("RGBA", "P"):
        image = image.convert("RGB")

    buffer = io.BytesIO()
    image.save(buffer, format=save_format, quality=90)
    buffer.seek(0)

    encoded = base64.b64encode(buffer.read()).decode("utf-8")
    return encoded, mime_type
