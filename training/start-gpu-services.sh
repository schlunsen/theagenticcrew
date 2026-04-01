#!/bin/bash
# Restart all GPU services after training is complete
set -e

echo "🚀 Restarting GPU services..."
echo "=============================="
echo ""

echo "▶  Starting vLLM container..."
docker start vllm

echo "▶  Starting Ollama..."
systemctl start ollama.service

echo "▶  Starting ComfyUI..."
systemctl start comfyui.service

echo "▶  Starting Fish Speech TTS..."
systemctl start fish-tts.service

echo "▶  Starting Kani TTS..."
systemctl start kani-tts.service

echo "▶  Starting Kokoro TTS..."
systemctl start kokoro-tts.service

echo "▶  Starting Anthropic proxy..."
systemctl start anthropic-proxy.service || true

echo ""
echo "⏳ Waiting for services to initialize..."
sleep 10

echo ""
nvidia-smi

echo ""
echo "✅ All GPU services restarted!"
