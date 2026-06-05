# 🇮🇳 Privacy-First Indic SLM
### Eskillveda Summer Internship 2026 — Technical Assessment

> An on-device Small Language Model that summarizes personal chats in multiple Indian languages — **100% offline, zero cloud dependency.**

---

## 📁 Project Structure

```
indic-slm/
├── backend/               # Inference scripts (llama-cpp-python + model download)
│   ├── app/               # Inference logic & routes
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
| Inference Engine   | llama-cpp-python       | Direct on-device inference, no server needed |
| Mobile UI | Flutter (Dart) | Cross-platform Android/iOS |
| Language Detection | langdetect + IndicNLP | Auto-detect Indian languages |

---

## 🚀 Quick Start

### 1. Setup Backend
```bash
cd backend
pip install -r requirements.txt
python scripts/download_model.py      # Downloads & quantizes model
python -m llama_cpp.server --model model/gemma-3-1b-it-Q4_K_M.gguf
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
## ✅ Demo — Verified Local Inference

Model runs fully offline via `llama-cpp-python`. No internet required after model download.

**Sample Hindi Output:**  
Input: `Raj: kal movie chalein? Priya: haan, KGF 2. Raj: 7 baje milte hain`  
Output: राज और प्रिया KGF 2 देखने की योजना बना रहे हैं, 7 बजे मिलेंगे।

Full multi-language results: [docs/sample_outputs/multi_language_inference.txt](docs/sample_outputs/multi_language_inference.txt)

---

## 👤 Author
**Prince Raj**  
Eskillveda Summer Internship 2026
