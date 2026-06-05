#!/bin/bash
# setup.sh — One-click backend setup for Indic SLM
set -e

echo "=================================================="
echo "  Privacy-First Indic SLM — Backend Setup"
echo "=================================================="
echo ""

# Check Python version
python3 --version || { echo "❌ Python 3 not found. Install from https://python.org"; exit 1; }

echo "📦 Installing Python dependencies..."
cd backend
pip install -r requirements.txt

echo ""
echo "⬇️  Downloading Gemma-3 1B GGUF model (~600 MB)..."
python scripts/download_model.py

echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 To start the server:"
echo "   cd backend"
echo "   uvicorn app.main:app --host 0.0.0.0 --port 8000"
echo ""
echo "📱 Then run the Flutter app:"
echo "   cd flutter_app"
echo "   flutter pub get && flutter run"
