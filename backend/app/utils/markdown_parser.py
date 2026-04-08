import json
import logging
import re

logger = logging.getLogger(__name__)

NOTES_MARKER = "## STRUCTURED_NOTES"
MINDMAP_MARKER = "## MIND_MAP_JSON"


def parse_recognition_response(text: str) -> tuple[str, dict]:
    """Split an AI recognition response into structured notes and a mind map dict.

    The expected format has two sections delimited by markers:
        ## STRUCTURED_NOTES
        ... markdown content ...

        ## MIND_MAP_JSON
        { ... json tree ... }

    Args:
        text: The raw text response from the AI provider.

    Returns:
        A tuple of (markdown_string, mind_map_dict).
        If parsing fails for either section, returns the full text as markdown
        and an empty dict for the mind map.
    """
    markdown = text
    mind_map: dict = {}

    notes_idx = text.find(NOTES_MARKER)
    mindmap_idx = text.find(MINDMAP_MARKER)

    if notes_idx != -1 and mindmap_idx != -1 and mindmap_idx > notes_idx:
        # Extract markdown between the two markers
        notes_start = notes_idx + len(NOTES_MARKER)
        markdown = text[notes_start:mindmap_idx].strip()

        # Extract JSON after the mind map marker
        json_text = text[mindmap_idx + len(MINDMAP_MARKER):].strip()
        mind_map = _extract_json(json_text)
    elif mindmap_idx != -1:
        # Only mind map marker found
        markdown = text[:mindmap_idx].strip()
        json_text = text[mindmap_idx + len(MINDMAP_MARKER):].strip()
        mind_map = _extract_json(json_text)
    elif notes_idx != -1:
        notes_start = notes_idx + len(NOTES_MARKER)
        markdown = text[notes_start:].strip()

    return markdown, mind_map


def _extract_json(text: str) -> dict:
    """Extract a JSON object from text, handling optional code fences."""
    # Strip markdown code fences if present
    cleaned = re.sub(r"^```(?:json)?\s*", "", text, flags=re.MULTILINE)
    cleaned = re.sub(r"```\s*$", "", cleaned, flags=re.MULTILINE)
    cleaned = cleaned.strip()

    # Find the JSON object boundaries
    start = cleaned.find("{")
    if start == -1:
        logger.warning("No JSON object found in mind map section")
        return {}

    # Find matching closing brace
    depth = 0
    for i, ch in enumerate(cleaned[start:], start=start):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                json_str = cleaned[start : i + 1]
                try:
                    return json.loads(json_str)
                except json.JSONDecodeError as exc:
                    logger.warning("Failed to parse mind map JSON: %s", exc)
                    return {}

    logger.warning("Unbalanced braces in mind map JSON")
    return {}
