from fastapi import APIRouter

from app.api.routes.auth import router as auth_router
from app.api.routes.notes import router as notes_router
from app.api.routes.recognition import router as recognition_router

api_router = APIRouter()
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(notes_router, prefix="/notes", tags=["notes"])
api_router.include_router(recognition_router, prefix="/recognition", tags=["recognition"])
