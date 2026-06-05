"""
main.py — FastAPI local inference server
Runs on localhost:8000, never touches the internet at runtime.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from pathlib import Path
import logging

from app.routes import summarize, health
from app.model_loader import load_model

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MODEL_PATH = Path(__file__).resolve().parents[2] / "model" / "gemma-3-1b-it-Q4_K_M.gguf"


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load model once at startup
    logger.info("Loading Gemma-3 1B GGUF model...")
    app.state.llm = load_model(str(MODEL_PATH))
    logger.info("✅ Model loaded. Server ready.")
    yield
    # Cleanup
    app.state.llm = None
    logger.info("Model unloaded.")


app = FastAPI(
    title="Indic SLM — Privacy-First Chat Summarizer",
    description="On-device summarization for Indian language chats. No cloud, no data leaks.",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow Flutter app on localhost to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(summarize.router)
