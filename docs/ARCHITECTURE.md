# Architecture & Design Documentation
## Privacy-First Indic SLM — Eskillveda Internship 2026

---

## 1. Problem Statement

Build an on-device Small Language Model (SLM) that:
- Summarizes personal chats in multiple Indian languages
- Runs **entirely on a mobile device** (no cloud)
- Uses a **4-bit quantized** model within **2GB RAM**

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────┐
│               MOBILE DEVICE                     │
│                                                 │
│  ┌──────────────┐     HTTP      ┌─────────────┐ │
│  │ Flutter App  │◄────────────►│  FastAPI    │ │
│  │  (UI Layer)  │  localhost    │  Server     │ │
│  └──────────────┘   :8000       └──────┬──────┘ │
│                                        │        │
│                               ┌────────▼──────┐ │
│                               │  llama.cpp    │ │
│                               │  (Inference)  │ │
│                               └────────┬──────┘ │
│                                        │        │
│                               ┌────────▼──────┐ │
│                               │ Gemma-3 1B    │ │
│                               │ Q4_K_M.gguf   │ │
│                               │ (~600 MB)     │ │
│                               └───────────────┘ │
│                                                 │
│  ❌ NO INTERNET  ❌ NO CLOUD  ❌ NO DATA SENT   │
└─────────────────────────────────────────────────┘
```

---

## 3. Technology Choices

### 3.1 Base Model: Gemma-3 1B (Google DeepMind)

**Why Gemma-3 1B?**
- Only 1 billion parameters — perfect for mobile hardware
- Strong multilingual support including all major Indic scripts
- Instruction-tuned variant (`gemma-3-1b-it`) follows summarization prompts well
- Apache 2.0 license — free for commercial use
- Outperforms older models (Phi-2, TinyLlama) on Indic language tasks

**Alternatives considered:**
| Model | Params | Indic Support | Decision |
|-------|--------|---------------|----------|
| Gemma-3 1B | 1B | ✅ Excellent | ✅ Chosen |
| Phi-3 Mini | 3.8B | ⚠️ Moderate | ❌ Too large |
| TinyLlama | 1.1B | ❌ Poor | ❌ Weak Indic |
| Llama 3.2 1B | 1B | ⚠️ Moderate | ❌ License restrictions |

---

### 3.2 Quantization: 4-bit GGUF (Q4_K_M)

**What is quantization?**
Quantization reduces model weights from 16-bit floats to 4-bit integers, shrinking the model by ~4x with minimal quality loss.

**Why Q4_K_M specifically?**
- `Q4` = 4-bit quantization (meets the task requirement)
- `K_M` = K-quant medium — best quality-to-size ratio in the 4-bit range
- Results in ~600 MB file vs ~2.5 GB original
- Fits comfortably within 2GB RAM when loaded

**GGUF format** (GPT-Generated Unified Format):
- Single file format designed for llama.cpp
- Memory-mapped loading — only loads needed parts into RAM
- No Python or GPU dependencies at inference time

---

### 3.3 Inference Engine: llama.cpp

**Why llama.cpp?**
- Pure C++ — runs on any CPU, no GPU required
- Memory-mapped file access — reduces RAM footprint
- Python bindings via `llama-cpp-python` for easy integration
- Battle-tested on millions of edge devices
- Supports 4-bit GGUF natively

---

### 3.4 Local API: FastAPI

**Why FastAPI?**
- Async Python — handles inference calls without blocking
- Auto-generates OpenAPI docs at `/docs`
- Pydantic validation for request/response schemas
- Runs on `localhost:8000` — only accessible from the device itself

---

### 3.5 Mobile Framework: Flutter

**Why Flutter?**
- Single codebase for Android + iOS
- Dart's async/await handles the slow inference calls gracefully
- Provider pattern for clean state management
- Google Fonts + Material 3 for Indic script rendering
- Noto Sans font family covers all Indian scripts

---

## 4. Privacy Design

### 4.1 Zero Cloud Dependency

The app **never sends data to any external server**:

```
Network requests at runtime:
✅ http://127.0.0.1:8000/summarize  ← localhost only
❌ api.openai.com                   ← never called
❌ api.anthropic.com                ← never called
❌ Any external URL                 ← never called
```

### 4.2 Android Manifest

`android:usesCleartextTraffic="true"` is required only for localhost HTTP.
In production, this would be restricted to `localhost` via a `network_security_config.xml`.

### 4.3 No Persistent Storage of Chats

The app does **not** save chat text to disk. All processing is in-memory only.

---

## 5. Language Detection Pipeline

```
Input Text
    │
    ▼
langdetect library
(statistical model — runs locally)
    │
    ├─── Detects: hi / bn / ta / te / mr / gu / kn / ml / en / etc.
    │
    ▼
Language-specific prompt template
(instructions written in native script)
    │
    ▼
Gemma-3 inference
    │
    ▼
Summary in same language as input
```

---

## 6. RAM Budget

| Component | RAM Usage |
|-----------|-----------|
| Gemma-3 1B Q4_K_M model | ~620 MB |
| llama.cpp runtime + KV cache | ~400 MB |
| FastAPI + Python runtime | ~120 MB |
| Flutter app | ~80 MB |
| OS overhead | ~200 MB |
| **Total** | **~1.42 GB** |

✅ Well within the 2GB limit.

---

## 7. Supported Languages

| Language | Code | Script | Prompt Language |
|----------|------|--------|-----------------|
| Hindi | hi | Devanagari | Hindi |
| Bengali | bn | Bengali | Bengali |
| Tamil | ta | Tamil | Tamil |
| Telugu | te | Telugu | Telugu |
| Marathi | mr | Devanagari | Marathi |
| Gujarati | gu | Gujarati | Gujarati |
| Kannada | kn | Kannada | Kannada |
| Malayalam | ml | Malayalam | Malayalam |
| English | en | Latin | English |

---

## 8. API Reference

### POST /summarize

**Request:**
```json
{
  "chat_text": "राज: कल मीटिंग है\nप्रिया: हाँ, 3 बजे",
  "language": "hi",
  "max_tokens": 300
}
```

**Response:**
```json
{
  "summary": "राज और प्रिया ने कल 3 बजे मीटिंग की पुष्टि की।",
  "detected_language": "hi",
  "language_name": "Hindi",
  "processing_time_sec": 11.4
}
```

### GET /health

```json
{
  "status": "ok",
  "model": "gemma-3-1b-it-Q4_K_M",
  "ram_used_gb": 1.42,
  "ram_total_gb": 6.0,
  "ram_percent": 23.7,
  "privacy": "on-device only"
}
```

---

## 9. Future Improvements

1. **ONNX Runtime Mobile** — run inference directly in Dart without FastAPI
2. **On-device quantization** — quantize model on first launch
3. **Streaming output** — stream tokens as they generate
4. **WhatsApp/Telegram export parser** — auto-parse exported chat `.txt` files
5. **Offline language detection** — replace `langdetect` with IndicNLP

---

*Submitted by Prince Raj — Eskillveda Summer Internship 2026*
