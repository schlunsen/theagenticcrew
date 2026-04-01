#!/bin/bash
# Stop all GPU-consuming services to free VRAM for training
# Run BEFORE training, restart after with start-gpu-services.sh
set -e

echo "🛑 Stopping GPU services to free VRAM..."
echo "========================================="
echo ""

# 1. vLLM (Docker container) — 83 GB VRAM
echo "⏹  Stopping vLLM container (83 GB)..."
docker stop vllm

# 2. Ollama — 5.4 GB VRAM
echo "⏹  Stopping Ollama service (5.4 GB)..."
systemctl stop ollama.service

# 3. ComfyUI — 0.5 GB VRAM
echo "⏹  Stopping ComfyUI (0.5 GB)..."
systemctl stop comfyui.service

# 4. Fish Speech TTS — 2.3 GB VRAM
echo "⏹  Stopping Fish Speech TTS (2.3 GB)..."
systemctl stop fish-tts.service

# 5. Kani TTS — 3 GB VRAM
echo "⏹  Stopping Kani TTS (3 GB)..."
systemctl stop kani-tts.service

# 6. Kokoro TTS — 2 GB VRAM
echo "⏹  Stopping Kokoro TTS (2 GB)..."
systemctl stop kokoro-tts.service

# 7. Anthropic proxy (depends on vLLM, may as well stop)
echo "⏹  Stopping Anthropic proxy..."
systemctl stop anthropic-proxy.service || true

echo ""
echo "⏳ Waiting for GPU memory to free..."
sleep 5

echo ""
nvidia-smi

echo ""
echo "✅ All GPU services stopped. ~96 GB VRAM should be free."
echo "   Ready to train! Run: cd /root/polly-training && source venv/bin/activate && python 02-train.py"
