#!/bin/bash
# Master script: runs the entire training pipeline end-to-end
# Usage: ./run-all.sh
set -e

TRAIN_DIR="/root/polly-training"
cd "$TRAIN_DIR"
source venv/bin/activate

echo "🦜 Polly Training Pipeline"
echo "=========================="
echo ""

# Step 0: Check ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY not set!"
    echo "   export ANTHROPIC_API_KEY=sk-..."
    exit 1
fi

# Step 1: Stop GPU services
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 0: Freeing GPU memory..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash stop-gpu-services.sh

# Step 2: Generate training data (runs on CPU, uses Claude API)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Generating Q&A training data..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python 01-generate-qa-data.py

# Step 3: Train
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Fine-tuning model..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python 02-train.py

# Step 4: Export to ONNX
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Exporting to ONNX..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python 03-export-onnx.py

# Step 5: Restart services
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Restarting GPU services..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash start-gpu-services.sh

echo ""
echo "🦜✅ DONE! Polly has been trained!"
echo ""
echo "Model files: $TRAIN_DIR/polly-model/onnx/"
echo ""
echo "Next: Upload to HuggingFace:"
echo "  huggingface-cli login"
echo "  huggingface-cli upload schlunsen/polly-qwen3.5-0.8b-onnx $TRAIN_DIR/polly-model/onnx/"
