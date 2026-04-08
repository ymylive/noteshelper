import os
import uuid

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.factory import get_provider
from app.api.deps import get_current_user
from app.config import settings
from app.database import get_db
from app.models.user import User
from app.schemas.note import NoteCreate, NoteResponse, MindMapResponse
from app.schemas.recognition import RecognitionResponse
from app.services.note_service import NoteService
from app.utils.image_processing import prepare_image
from app.utils.markdown_parser import parse_recognition_response

router = APIRouter()

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}


@router.post("/", response_model=RecognitionResponse, status_code=status.HTTP_201_CREATED)
async def recognize_image(
    file: UploadFile = File(...),
    provider: str = Form(default="claude"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> RecognitionResponse:
    if provider not in ("claude", "openai", "gemini"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provider must be one of: claude, openai, gemini",
        )

    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image type: {file.content_type}. Allowed: {', '.join(ALLOWED_MIME_TYPES)}",
        )

    file_bytes = await file.read()
    if len(file_bytes) > 20 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image must be smaller than 20 MB",
        )

    image_b64, mime_type = prepare_image(file_bytes)

    ai_provider = get_provider(provider, settings)
    result = await ai_provider.recognize(image_b64, mime_type)

    markdown_content, mind_map_tree = parse_recognition_response(result.structured_markdown)

    # Save uploaded image to disk
    upload_dir = settings.UPLOAD_DIR
    os.makedirs(upload_dir, exist_ok=True)
    file_ext = mime_type.split("/")[-1]
    saved_filename = f"{uuid.uuid4()}.{file_ext}"
    saved_path = os.path.join(upload_dir, saved_filename)
    with open(saved_path, "wb") as f:
        f.write(file_bytes)

    # Use the AI-generated mind map tree if parsing failed to extract one
    if not mind_map_tree:
        mind_map_tree = result.mind_map_tree

    title_line = markdown_content.strip().split("\n")[0] if markdown_content.strip() else "Untitled Note"
    title = title_line.lstrip("# ").strip()[:500] or "Untitled Note"

    note_service = NoteService(db)
    note = await note_service.create_note(
        user_id=current_user.id,
        data=NoteCreate(
            title=title,
            content_markdown=markdown_content,
            source_image_url=f"/uploads/{saved_filename}",
            ai_provider_used=provider,
        ),
        mind_map_tree=mind_map_tree,
    )

    return RecognitionResponse(
        note=NoteResponse.model_validate(note),
        mind_map=MindMapResponse.model_validate(note.mind_map),
    )
