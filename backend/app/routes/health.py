"""
routes/health.py
----------------
GET /health — lets the Flutter app check if the server is running.
"""

from fastapi import APIRouter
import psutil
import os

router = APIRouter()


@router.get("/health")
async def health_check():
    mem = psutil.virtual_memory()
    return {
        "status": "ok",
        "model": "gemma-3-1b-it-Q4_K_M",
        "ram_used_gb": round(mem.used / (1024 ** 3), 2),
        "ram_total_gb": round(mem.total / (1024 ** 3), 2),
        "ram_percent": mem.percent,
        "privacy": "on-device only",
    }
