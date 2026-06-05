# 🇮🇳 Privacy-First Indic SLM
### Eskillveda Summer Internship 2026 — Technical Assessment

> An on-device Small Language Model that summarizes personal chats in multiple Indian languages — **100% offline, zero cloud dependency.**

---

## 📁 Project Structure

```
indic-slm/
├── backend/               # Python inference server (llama.cpp + FastAPI)
│   ├── app/               # FastAPI app & routes
│   └── scripts/           # Model download & quantization scripts
├── model/                 # GGUF model stored here (downloaded via script)
├── flutter_app/           # Flutter mobile application
│   └── lib/
│       ├── screens/       # UI screens
│       ├── widgets/       # Reusable UI components
│       ├── services/      # API & language detection services
│       └── models/        # Data models
└── docs/                  # Architecture diagrams & documentation
```

---

## ⚙️ Tech Stack

| Layer | Tool | Reason |
|-------|------|--------|
| Base Model | Gemma-3 1B (Google) | Best Indic language support in <1B params |
| Quantization | 4-bit GGUF (llama.cpp) | Reduces to ~600MB, fits in 2GB RAM |
| Inference | llama-cpp-python | CPU-only inference, no GPU required |
| Local API | FastAPI + Uvicorn | Lightweight REST server on localhost |
| Mobile UI | Flutter (Dart) | Cross-platform Android/iOS |
| Language Detection | langdetect + IndicNLP | Auto-detect Indian languages |

---

## 🚀 Quick Start

### 1. Setup Backend
```bash
cd backend
pip install -r requirements.txt
python scripts/download_model.py      # Downloads & quantizes model
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 2. Run Flutter App
```bash
cd flutter_app
flutter pub get
flutter run
```

---

## 🌐 Supported Languages

| Language | Code | Script |
|----------|------|--------|
| Hindi | hi | Devanagari |
| Bengali | bn | Bengali |
| Tamil | ta | Tamil |
| Telugu | te | Telugu |
| Marathi | mr | Devanagari |
| Gujarati | gu | Gujarati |
| Kannada | kn | Kannada |
| Malayalam | ml | Malayalam |
| English | en | Latin |

---

## 🔒 Privacy Design

- ✅ All inference happens **on-device**
- ✅ No internet permission required at runtime
- ✅ Chat data **never leaves the phone**
- ✅ Model loaded into RAM, no external calls
- ✅ Works fully in **airplane mode**

---

## 📊 Performance Benchmarks

| Metric | Value |
|--------|-------|
| Model Size (GGUF 4-bit) | ~600 MB |
| RAM Usage at Runtime | ~1.4 GB |
| Avg. Summarization Time | 8–15 sec (CPU) |
| Supported Context Length | 2048 tokens |

---

## 👤 Author
**Prince Raj**  
Eskillveda Summer Internship 2026
