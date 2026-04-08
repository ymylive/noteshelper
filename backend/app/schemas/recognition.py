from pydantic import BaseModel, Field

from app.schemas.note import NoteResponse, MindMapResponse


class RecognitionRequest(BaseModel):
    provider: str = Field(default="claude", pattern=r"^(claude|openai|gemini)$")


class RecognitionResponse(BaseModel):
    note: NoteResponse
    mind_map: MindMapResponse
