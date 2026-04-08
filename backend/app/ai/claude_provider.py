import base64
import json
import logging

import anthropic

from app.ai.base import BaseAIProvider, RecognitionResult
from app.ai.prompts import RECOGNITION_PROMPT
from app.utils.markdown_parser import parse_recognition_response

logger = logging.getLogger(__name__)


class ClaudeProvider(BaseAIProvider):
    def __init__(self, api_key: str) -> None:
        self.client = anthropic.AsyncAnthropic(api_key=api_key)

    async def recognize(self, image_base64: str, mime_type: str) -> RecognitionResult:
        message = await self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=4096,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": mime_type,
                                "data": image_base64,
                            },
                        },
                        {
                            "type": "text",
                            "text": RECOGNITION_PROMPT,
                        },
                    ],
                }
            ],
        )

        response_text = message.content[0].text
        markdown, mind_map_tree = parse_recognition_response(response_text)

        return RecognitionResult(
            structured_markdown=response_text,
            mind_map_tree=mind_map_tree,
        )
