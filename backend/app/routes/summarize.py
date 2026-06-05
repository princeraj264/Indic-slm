"""
routes/summarize.py
-------------------
POST /summarize  — core endpoint used by the Flutter app.
Accepts chat text, detects language, returns summary in same language.
"""

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel, Field
from app.model_loader import get_model
from app.language_utils import detect_language, get_prompt
import logging
import time

router = APIRouter()
logger = logging.getLogger(__name__)


class SummarizeRequest(BaseModel):
    chat_text: str = Field(..., min_length=10, description="Raw chat conversation text")
    language: str | None = Field(None, description="ISO language code. Auto-detected if not provided.")
    max_tokens: int = Field(300, ge=50, le=600)


class SummarizeResponse(BaseModel):
    summary: str
    detected_language: str
    language_name: str
    processing_time_sec: float


LANGUAGE_NAMES = {
    "hi": "Hindi", "bn": "Bengali", "ta": "Tamil", "te": "Telugu",
    "mr": "Marathi", "gu": "Gujarati", "kn": "Kannada", "ml": "Malayalam",
    "en": "English", "pa": "Punjabi", "ur": "Urdu",
}


@router.post("/summarize", response_model=SummarizeResponse)
async def summarize_chat(req: SummarizeRequest, request: Request):
    llm = get_model()

    # Detect language
    lang_code = req.language or detect_language(req.chat_text)
    lang_name = LANGUAGE_NAMES.get(lang_code, "Unknown")
    logger.info(f"Summarizing in: {lang_name} ({lang_code})")

    # Build prompt
    prompt = get_prompt(req.chat_text, lang_code)

    # Run inference
    t0 = time.time()
    try:
        output = llm(
            prompt,
            max_tokens=req.max_tokens,
            temperature=0.3,       # Lower = more factual
            top_p=0.9,
            stop=["</s>", "###", "Human:", "User:"],
            echo=False,
        )
    except Exception as e:
        logger.error(f"Inference failed: {e}")
        raise HTTPException(status_code=500, detail=f"Inference error: {str(e)}")

    elapsed = round(time.time() - t0, 2)
    summary = output["choices"][0]["text"].strip()

    return SummarizeResponse(
        summary=summary,
        detected_language=lang_code,
        language_name=lang_name,
        processing_time_sec=elapsed,
    )
