#!/usr/bin/env python3
"""
Step 2: Fine-tune Qwen3.5-0.8B on the generated Q&A data.

Requires: pip install unsloth trl datasets
Hardware: NVIDIA GPU with >= 16GB VRAM (96GB ideal for full fine-tune)

Usage:
    python 02-train.py
    python 02-train.py --epochs 5 --lr 1e-5  # custom hyperparams
"""

import argparse
import json
from pathlib import Path

# Check dependencies
try:
    from unsloth import FastLanguageModel
    from trl import SFTTrainer, SFTConfig
    from datasets import Dataset
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Run: pip install unsloth trl datasets")
    exit(1)

TRAINING_DATA = Path(__file__).parent / "training_data.jsonl"
OUTPUT_DIR = Path(__file__).parent / "polly-model"


def load_dataset_from_jsonl(path: Path) -> Dataset:
    """Load JSONL training data into a HuggingFace Dataset."""
    examples = []
    with open(path) as f:
        for line in f:
            examples.append(json.loads(line))
    return Dataset.from_list(examples)


def format_chat(example, tokenizer):
    """Format a single example using the model's chat template."""
    text = tokenizer.apply_chat_template(
        example["messages"],
        tokenize=False,
        add_generation_prompt=False,
    )
    return {"text": text}


def main():
    parser = argparse.ArgumentParser(description="Fine-tune Polly")
    parser.add_argument("--epochs", type=int, default=3, help="Training epochs (default: 3)")
    parser.add_argument("--lr", type=float, default=2e-5, help="Learning rate (default: 2e-5)")
    parser.add_argument("--batch-size", type=int, default=4, help="Batch size (default: 4)")
    parser.add_argument("--max-seq-len", type=int, default=2048, help="Max sequence length")
    parser.add_argument("--lora", action="store_true", help="Use LoRA instead of full fine-tune")
    parser.add_argument("--lora-r", type=int, default=64, help="LoRA rank (default: 64)")
    args = parser.parse_args()

    if not TRAINING_DATA.exists():
        print(f"❌ Training data not found: {TRAINING_DATA}")
        print("Run 01-generate-qa-data.py first!")
        return

    # Load data
    print(f"📂 Loading training data from {TRAINING_DATA}...")
    dataset = load_dataset_from_jsonl(TRAINING_DATA)
    print(f"   {len(dataset)} examples loaded")

    # Split: 90% train, 10% eval
    split = dataset.train_test_split(test_size=0.1, seed=42)
    train_dataset = split["train"]
    eval_dataset = split["test"]
    print(f"   Train: {len(train_dataset)}, Eval: {len(eval_dataset)}")

    # Load model
    print(f"\n🤖 Loading Qwen3.5-0.8B...")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name="Qwen/Qwen3.5-0.8B",
        max_seq_length=args.max_seq_len,
        load_in_4bit=False,  # Full precision — we have the VRAM
        dtype=None,  # Auto-detect (bf16 on Ampere+)
    )

    # Unsloth requires get_peft_model to make parameters trainable.
    # Use high-rank LoRA (r=128) which covers most of the model's capacity
    # and is more memory-efficient than true full fine-tune.
    lora_r = args.lora_r if args.lora else 128
    print(f"   Using LoRA with r={lora_r} ({'user-specified' if args.lora else 'high-rank for near-full fine-tune'})")
    model = FastLanguageModel.get_peft_model(
        model,
        r=lora_r,
        lora_alpha=lora_r * 2,
        lora_dropout=0,
        target_modules=[
            "q_proj", "k_proj", "v_proj", "o_proj",
            "gate_proj", "up_proj", "down_proj",
        ],
        bias="none",
        use_gradient_checkpointing="unsloth",
    )

    # Format dataset with chat template
    print("\n📝 Formatting training data...")
    train_dataset = train_dataset.map(
        lambda x: format_chat(x, tokenizer),
        remove_columns=train_dataset.column_names,
    )
    eval_dataset = eval_dataset.map(
        lambda x: format_chat(x, tokenizer),
        remove_columns=eval_dataset.column_names,
    )

    # Train
    print(f"\n🚀 Training for {args.epochs} epochs, lr={args.lr}, batch_size={args.batch_size}")
    print(f"   Output: {OUTPUT_DIR}")

    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset,
        args=SFTConfig(
            output_dir=str(OUTPUT_DIR),
            per_device_train_batch_size=args.batch_size,
            per_device_eval_batch_size=args.batch_size,
            gradient_accumulation_steps=2,
            num_train_epochs=args.epochs,
            learning_rate=args.lr,
            warmup_ratio=0.1,
            weight_decay=0.01,
            logging_steps=10,
            eval_strategy="epoch",
            save_strategy="epoch",
            save_total_limit=2,
            bf16=True,
            seed=42,
            max_seq_length=args.max_seq_len,
            dataset_text_field="text",
            report_to="none",
        ),
    )

    print("\n" + "=" * 60)
    trainer.train()
    print("=" * 60)

    # Save LoRA adapter
    final_dir = OUTPUT_DIR / "final"
    print(f"\n💾 Saving LoRA adapter to {final_dir}...")
    model.save_pretrained(final_dir)
    tokenizer.save_pretrained(final_dir)

    # Always merge LoRA into base model for ONNX export
    merged_dir = OUTPUT_DIR / "merged"
    print(f"💾 Merging LoRA into base model at {merged_dir}...")
    model.save_pretrained_merged(merged_dir, tokenizer)

    print(f"\n✅ Training complete!")
    print(f"   LoRA adapter: {final_dir}")
    print(f"   Merged model: {merged_dir}")
    print(f"\n   Next step: python 03-export-onnx.py")


if __name__ == "__main__":
    main()
