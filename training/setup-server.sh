#!/bin/bash
# Setup script for the training server
# Run this ONCE on the remote machine to install dependencies
set -e

echo "🔧 Setting up Polly training environment..."
echo "============================================"

# Create a virtual environment
TRAIN_DIR="/root/polly-training"
mkdir -p "$TRAIN_DIR"
cd "$TRAIN_DIR"

echo ""
echo "📦 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo ""
echo "📦 Installing PyTorch (CUDA)..."
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

echo ""
echo "📦 Installing training dependencies..."
pip install unsloth trl datasets anthropic
pip install optimum[exporters] onnx onnxruntime-gpu
pip install huggingface_hub

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Stop GPU processes:  ./stop-gpu-services.sh"
echo "  2. Generate Q&A data:   python 01-generate-qa-data.py"
echo "  3. Train model:         python 02-train.py"
echo "  4. Export to ONNX:      python 03-export-onnx.py"
echo "  5. Restart services:    ./start-gpu-services.sh"
