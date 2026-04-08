from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class RecognitionResult:
    structured_markdown: str
    mind_map_tree: dict = field(default_factory=dict)


class BaseAIProvider(ABC):
    @abstractmethod
    async def recognize(self, image_base64: str, mime_type: str) -> RecognitionResult:
        """Analyze an image and return structured notes with a mind map tree.

        Args:
            image_base64: Base64-encoded image data.
            mime_type: MIME type of the image (e.g. "image/png").

        Returns:
            RecognitionResult with structured markdown and mind map JSON.
        """
        ...
