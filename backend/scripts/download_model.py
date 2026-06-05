"""
download_model.py
-----------------
Downloads Gemma-3 1B in GGUF 4-bit quantized format from HuggingFace.
No GPU required. Model is stored in /model directory.
"""

import os
import sys
from pathlib import Path
from huggingface_hub import hf_hub_download

# ── Config ──────────────────────────────────────────────────────────────────
MODEL_REPO   = "bartowski/gemma-3-1b-it-GGUF"
MODEL_FILE   = "gemma-3-1b-it-Q4_K_M.gguf"   # 4-bit quantized, ~600 MB
MODEL_DIR    = Path(__file__).resolve().parents[2] / "model"
MODEL_PATH   = MODEL_DIR / MODEL_FILE
# ────────────────────────────────────────────────────────────────────────────


def download():
    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    if MODEL_PATH.exists():
        size_mb = MODEL_PATH.stat().st_size / (1024 * 1024)
        print(f"✅ Model already exists: {MODEL_PATH}  ({size_mb:.0f} MB)")
        return str(MODEL_PATH)

    print(f"⬇️  Downloading {MODEL_FILE} from HuggingFace...")
    print(f"    Repo : {MODEL_REPO}")
    print(f"    Dest : {MODEL_DIR}")
    print("    This may take a few minutes (~600 MB)...\n")

    path = hf_hub_download(
        repo_id=MODEL_REPO,
        filename=MODEL_FILE,
        local_dir=str(MODEL_DIR),
        local_dir_use_symlinks=False,
    )

    size_mb = Path(path).stat().st_size / (1024 * 1024)
    print(f"\n✅ Download complete! ({size_mb:.0f} MB)")
    print(f"   Saved to: {path}")
    return path


def verify(model_path: str):
    """Quick sanity check — load model and run a test prompt."""
    print("\n🔍 Verifying model loads correctly...")
    try:
        from llama_cpp import Llama
        llm = Llama(
            model_path=model_path,
            n_ctx=512,
            n_threads=4,
            verbose=False,
        )
        out = llm("Hello", max_tokens=10)
        print("✅ Model verified — inference working!")
    except Exception as e:
        print(f"⚠️  Verification failed: {e}")
        print("   Model file may be incomplete. Try re-running this script.")
        sys.exit(1)


if __name__ == "__main__":
    path = download()
    verify(path)
    print("\n🚀 Ready! Start the server with:")
    print("   cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000")
