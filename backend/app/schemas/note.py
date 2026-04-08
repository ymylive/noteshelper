import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class NoteCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=500)
    content_markdown: str = ""
    source_image_url: str | None = None
    ai_provider_used: str | None = None


class NoteUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=500)
    content_markdown: str | None = None


class MindMapResponse(BaseModel):
    id: uuid.UUID
    note_id: uuid.UUID
    tree_data: dict
    layout_data: dict | None = None
    updated_at: datetime

    model_config = {"from_attributes": True}


class MindMapUpdate(BaseModel):
    tree_data: dict | None = None
    layout_data: dict | None = None


class NoteResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    content_markdown: str
    source_image_url: str | None = None
    ai_provider_used: str | None = None
    created_at: datetime
    updated_at: datetime
    mind_map: MindMapResponse | None = None

    model_config = {"from_attributes": True}


class NoteListResponse(BaseModel):
    items: list[NoteResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
