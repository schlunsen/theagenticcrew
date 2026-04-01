#!/usr/bin/env python3
"""
Step 3: Export the fine-tuned model to ONNX format with Q4 quantization
for deployment via Transformers.js in the browser.

Usage:
    python 03-export-onnx.py
    python 03-export-onnx.py --quantize q8  # less compression, better quality
"""

import argparse
import shutil
from pathlib import Path

MODEL_DIR = Path(__file__).parent / "polly-model" / "merged"
ONNX_DIR = Path(__file__).parent / "polly-model" / "onnx"


def main():
    parser = argparse.ArgumentParser(description="Export Polly to ONNX")
    parser.add_argument("--quantize", default="q4", choices=["q4", "q8", "fp16", "none"],
                        help="Quantization level (default: q4)")
    parser.add_argument("--model-dir", type=Path, default=MODEL_DIR,
                        help="Path to fine-tuned model")
    args = parser.parse_args()

    if not args.model_dir.exists():
        print(f"❌ Model not found: {args.model_dir}")
        print("Run 02-train.py first!")
        return

    print(f"📦 Exporting model from {args.model_dir}")
    print(f"   Quantization: {args.quantize}")
    print(f"   Output: {ONNX_DIR}")

    # Step 1: Export to ONNX using optimum Python API (in-process)
    # This avoids subprocess issues where model type isn't recognized
    print("\n🔄 Step 1: ONNX export...")
    try:
        from optimum.exporters.onnx import main_export
        from transformers import AutoConfig

        # Ensure output dir exists
        ONNX_DIR.mkdir(parents=True, exist_ok=True)

        main_export(
            model_name_or_path=str(args.model_dir),
            output=ONNX_DIR,
            task="text-generation-with-past",
            do_validation=False,
            no_post_process=False,
        )
    except Exception as e:
        print(f"   optimum export failed: {e}")
        print("   Falling back to torch.onnx.export...")

        try:
            _torch_onnx_export(args.model_dir, ONNX_DIR)
        except Exception as e2:
            print(f"❌ Both export methods failed!")
            print(f"   optimum error: {e}")
            print(f"   torch error: {e2}")
            return

    # Step 2: Quantize
    if args.quantize != "none":
        print(f"\n🔄 Step 2: Quantizing to {args.quantize}...")

        if args.quantize in ("q4", "q8"):
            try:
                from onnxruntime.quantization import quantize_dynamic, QuantType

                quant_type = QuantType.QUInt4 if args.quantize == "q4" else QuantType.QUInt8
                onnx_files = list(ONNX_DIR.glob("*.onnx"))

                for onnx_file in onnx_files:
                    if "quantized" in onnx_file.name or "_q4" in onnx_file.name or "_q8" in onnx_file.name:
                        continue
                    out_name = onnx_file.stem + f"_{args.quantize}" + onnx_file.suffix
                    out_path = ONNX_DIR / out_name
                    print(f"   Quantizing {onnx_file.name} -> {out_name}...")
                    quantize_dynamic(
                        str(onnx_file),
                        str(out_path),
                        weight_type=quant_type,
                    )
            except ImportError:
                print("   ⚠ onnxruntime not found, skipping quantization")
                print("   Install: pip install onnxruntime")

    # Copy tokenizer files
    print("\n📋 Copying tokenizer files...")
    for f in args.model_dir.iterdir():
        if f.name in ("tokenizer.json", "tokenizer_config.json", "special_tokens_map.json",
                       "vocab.json", "merges.txt", "tokenizer.model", "config.json",
                       "generation_config.json"):
            dest = ONNX_DIR / f.name
            if not dest.exists():
                shutil.copy2(f, dest)
                print(f"   Copied {f.name}")

    # Summary
    print("\n✅ ONNX export complete!")
    print(f"   Output directory: {ONNX_DIR}")
    print("\n   Files:")
    total_size = 0
    for f in sorted(ONNX_DIR.iterdir()):
        size_mb = f.stat().st_size / 1024 / 1024
        total_size += size_mb
        print(f"   {f.name:50s} {size_mb:8.1f} MB")
    print(f"   {'TOTAL':50s} {total_size:8.1f} MB")

    print(f"\n   Next step: Upload to HuggingFace Hub:")
    print(f"   huggingface-cli upload schlunsen/polly-qwen3.5-0.8b-onnx {ONNX_DIR}")


def _torch_onnx_export(model_dir, output_dir):
    """Fallback: export using torch.onnx.export directly."""
    import torch
    from transformers import AutoModelForCausalLM, AutoTokenizer

    print("   Loading model...")
    model = AutoModelForCausalLM.from_pretrained(str(model_dir), torch_dtype=torch.float32)
    tokenizer = AutoTokenizer.from_pretrained(str(model_dir))
    model.eval()

    output_dir.mkdir(parents=True, exist_ok=True)

    # Create dummy input
    dummy_input = tokenizer("Hello", return_tensors="pt")
    input_ids = dummy_input["input_ids"]
    attention_mask = dummy_input["attention_mask"]

    print("   Exporting to ONNX...")
    onnx_path = output_dir / "model.onnx"
    torch.onnx.export(
        model,
        (input_ids, attention_mask),
        str(onnx_path),
        input_names=["input_ids", "attention_mask"],
        output_names=["logits"],
        dynamic_axes={
            "input_ids": {0: "batch_size", 1: "sequence_length"},
            "attention_mask": {0: "batch_size", 1: "sequence_length"},
            "logits": {0: "batch_size", 1: "sequence_length"},
        },
        opset_version=17,
        do_constant_folding=True,
    )
    print(f"   Saved to {onnx_path}")


if __name__ == "__main__":
    main()
