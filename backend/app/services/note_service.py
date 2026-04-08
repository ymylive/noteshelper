import uuid
from datetime import datetime, timezone

from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.mind_map import MindMap
from app.models.note import Note
from app.schemas.note import NoteCreate, NoteUpdate, MindMapUpdate


class NoteService:
    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def create_note(
        self,
        user_id: uuid.UUID,
        data: NoteCreate,
        mind_map_tree: dict | None = None,
    ) -> Note:
        note = Note(
            user_id=user_id,
            title=data.title,
            content_markdown=data.content_markdown,
            source_image_url=data.source_image_url,
            ai_provider_used=data.ai_provider_used,
        )
        self.db.add(note)
        await self.db.flush()

        if mind_map_tree is not None:
            mind_map = MindMap(
                note_id=note.id,
                tree_data=mind_map_tree,
            )
            self.db.add(mind_map)
            await self.db.flush()

        await self.db.refresh(note, attribute_names=["mind_map"])
        return note

    async def get_notes(
        self, user_id: uuid.UUID, page: int = 1, page_size: int = 20
    ) -> tuple[list[Note], int]:
        # Count total
        count_stmt = select(func.count()).select_from(Note).where(Note.user_id == user_id)
        total_result = await self.db.execute(count_stmt)
        total = total_result.scalar_one()

        # Fetch page
        offset = (page - 1) * page_size
        stmt = (
            select(Note)
            .where(Note.user_id == user_id)
            .options(selectinload(Note.mind_map))
            .order_by(desc(Note.updated_at))
            .offset(offset)
            .limit(page_size)
        )
        result = await self.db.execute(stmt)
        items = list(result.scalars().all())

        return items, total

    async def get_note(self, note_id: uuid.UUID, user_id: uuid.UUID) -> Note | None:
        stmt = (
            select(Note)
            .where(Note.id == note_id, Note.user_id == user_id)
            .options(selectinload(Note.mind_map))
        )
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def update_note(
        self, note_id: uuid.UUID, user_id: uuid.UUID, data: NoteUpdate
    ) -> Note | None:
        note = await self.get_note(note_id, user_id)
        if not note:
            return None

        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(note, field, value)

        note.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        await self.db.refresh(note)
        return note

    async def delete_note(self, note_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        note = await self.get_note(note_id, user_id)
        if not note:
            return False
        await self.db.delete(note)
        await self.db.flush()
        return True

    async def get_mindmap(self, note_id: uuid.UUID, user_id: uuid.UUID) -> MindMap | None:
        note = await self.get_note(note_id, user_id)
        if not note:
            return None
        return note.mind_map

    async def update_mindmap(
        self, note_id: uuid.UUID, user_id: uuid.UUID, data: MindMapUpdate
    ) -> MindMap | None:
        note = await self.get_note(note_id, user_id)
        if not note or not note.mind_map:
            return None

        mind_map = note.mind_map
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(mind_map, field, value)

        mind_map.updated_at = datetime.now(timezone.utc)
        await self.db.flush()
        await self.db.refresh(mind_map)
        return mind_map
