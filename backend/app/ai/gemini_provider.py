import base64
import json
import logging

import google.generativeai as genai

from app.ai.base import BaseAIProvider, RecognitionResult
from app.ai.prompts import RECOGNITION_PROMPT
from app.utils.markdown_parser import parse_recognition_response

logger = logging.getLogger(__name__)


class GeminiProvider(BaseAIProvider):
    def __init__(self, api_key: str) -> None:
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel("gemini-1.5-pro")

    async def recognize(self, image_base64: str, mime_type: str) -> RecognitionResult:
        image_bytes = base64.b64decode(image_base64)

        image_part = {
            "mime_type": mime_type,
            "data": image_bytes,
        }

        response = await self.model.generate_content_async(
            [image_part, RECOGNITION_PROMPT],
            generation_config=genai.GenerationConfig(max_output_tokens=4096),
        )

        response_text = response.text or ""
        markdown, mind_map_tree = parse_recognition_response(response_text)

        return RecognitionResult(
            structured_markdown=response_text,
            mind_map_tree=mind_map_tree,
        )
