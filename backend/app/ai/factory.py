from app.ai.base import BaseAIProvider
from app.ai.claude_provider import ClaudeProvider
from app.ai.openai_provider import OpenAIProvider
from app.ai.gemini_provider import GeminiProvider
from app.config import Settings


def get_provider(name: str, config: Settings) -> BaseAIProvider:
    """Return an AI provider instance by name.

    Args:
        name: One of "claude", "openai", or "gemini".
        config: Application settings containing API keys.

    Returns:
        An instance of the requested AI provider.

    Raises:
        ValueError: If the provider name is unknown or the API key is missing.
    """
    providers: dict[str, tuple[type[BaseAIProvider], str]] = {
        "claude": (ClaudeProvider, config.ANTHROPIC_API_KEY),
        "openai": (OpenAIProvider, config.OPENAI_API_KEY),
        "gemini": (GeminiProvider, config.GOOGLE_API_KEY),
    }

    if name not in providers:
        raise ValueError(f"Unknown AI provider: {name}. Must be one of: {', '.join(providers)}")

    provider_cls, api_key = providers[name]

    if not api_key:
        raise ValueError(
            f"API key for provider '{name}' is not configured. "
            f"Set the corresponding environment variable in your .env file."
        )

    return provider_cls(api_key=api_key)
