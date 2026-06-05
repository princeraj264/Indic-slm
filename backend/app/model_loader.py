"""
model_loader.py
---------------
Loads the GGUF model once and keeps it in memory.
Settings are tuned for mobile-class hardware (2GB RAM target).
"""

from llama_cpp import Llama
import logging

logger = logging.getLogger(__name__)

_llm_instance = None


def load_model(model_path: str) -> Llama:
    global _llm_instance
    if _llm_instance is not None:
        return _llm_instance

    _llm_instance = Llama(
        model_path=model_path,
        n_ctx=2048,          # Context window
        n_threads=4,         # CPU threads (adjust for device)
        n_gpu_layers=0,      # 0 = CPU only (no GPU needed)
        use_mmap=True,       # Memory-mapped file (reduces RAM)
        use_mlock=False,     # Don't lock RAM pages
        verbose=False,
    )
    logger.info(f"Model loaded from: {model_path}")
    return _llm_instance


def get_model() -> Llama:
    if _llm_instance is None:
        raise RuntimeError("Model not loaded. Start server via main.py")
    return _llm_instance
