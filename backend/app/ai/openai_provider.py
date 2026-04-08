import base64
import json
import logging

import openai

from app.ai.base import BaseAIProvider, RecognitionResult
from app.ai.prompts import RECOGNITION_PROMPT
from app.utils.markdown_parser import parse_recognition_response

logger = logging.getLogger(__name__)


class OpenAIProvider(BaseAIProvider):
    def __init__(self, api_key: str) -> None:
        self.client = openai.AsyncOpenAI(api_key=api_key)

    async def recognize(self, image_base64: str, mime_type: str) -> RecognitionResult:
        data_url = f"data:{mime_type};base64,{image_base64}"

        response = await self.client.chat.completions.create(
            model="gpt-4o",
            max_tokens=4096,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image_url",
                            "image_url": {"url": data_url, "detail": "high"},
                        },
                        {
                            "type": "text",
                            "text": RECOGNITION_PROMPT,
                        },
                    ],
                }
            ],
        )

        response_text = response.choices[0].message.content or ""
        markdown, mind_map_tree = parse_recognition_response(response_text)

        return RecognitionResult(
            structured_markdown=response_text,
            mind_map_tree=mind_map_tree,
        )
