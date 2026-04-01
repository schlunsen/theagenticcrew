#!/usr/bin/env python3
"""
Step 2b: Fine-tune Qwen2.5-0.5B on the generated Q&A data.
Uses a model with full ONNX export support for browser deployment.

Usage:
    python 02b-train-qwen25.py
"""

import argparse
import json
import socket
from pathlib import Path

# Force IPv4 (Hetzner IPv6 hangs on HuggingFace)
_orig_getaddrinfo = socket.getaddrinfo
def _ipv4_only(*args, **kwargs):
    return [r for r in _orig_getaddrinfo(*args, **kwargs) if r[0] == socket.AF_INET]
socket.getaddrinfo = _ipv4_only

try:
    from unsloth import FastLanguageModel
    from trl import SFTTrainer, SFTConfig
    from datasets import Dataset
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Run: pip install unsloth trl datasets")
    exit(1)

TRAINING_DATA = Path(__file__).parent / "training_data_merged.jsonl"
OUTPUT_DIR = Path(__file__).parent / "polly-qwen25"


def load_dataset_from_jsonl(path: Path) -> Dataset:
    examples = []
    with open(path) as f:
        for line in f:
            examples.append(json.loads(line))
    return Dataset.from_list(examples)


def format_chat(example, tokenizer):
    text = tokenizer.apply_chat_template(
        example["messages"],
        tokenize=False,
        add_generation_prompt=False,
    )
    return {"text": text}


def main():
    parser = argparse.ArgumentParser(description="Fine-tune Polly on Qwen2.5-0.5B")
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--lr", type=float, default=2e-5)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--max-seq-len", type=int, default=2048)
    parser.add_argument("--lora-r", type=int, default=128)
    args = parser.parse_args()

    if not TRAINING_DATA.exists():
        print(f"Training data not found: {TRAINING_DATA}")
        return

    print(f"Loading training data from {TRAINING_DATA}...")
    dataset = load_dataset_from_jsonl(TRAINING_DATA)
    print(f"   {len(dataset)} examples loaded")

    split = dataset.train_test_split(test_size=0.1, seed=42)
    train_dataset = split["train"]
    eval_dataset = split["test"]
    print(f"   Train: {len(train_dataset)}, Eval: {len(eval_dataset)}")

    print(f"\nLoading Qwen2.5-0.5B-Instruct...")
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name="Qwen/Qwen2.5-0.5B-Instruct",
        max_seq_length=args.max_seq_len,
        load_in_4bit=False,
        dtype=None,
    )

    print(f"   Using LoRA with r={args.lora_r}")
    model = FastLanguageModel.get_peft_model(
        model,
        r=args.lora_r,
        lora_alpha=args.lora_r * 2,
        lora_dropout=0,
        target_modules=[
            "q_proj", "k_proj", "v_proj", "o_proj",
            "gate_proj", "up_proj", "down_proj",
        ],
        bias="none",
        use_gradient_checkpointing="unsloth",
    )

    print("\nFormatting training data...")
    train_dataset = train_dataset.map(
        lambda x: format_chat(x, tokenizer),
        remove_columns=train_dataset.column_names,
    )
    eval_dataset = eval_dataset.map(
        lambda x: format_chat(x, tokenizer),
        remove_columns=eval_dataset.column_names,
    )

    print(f"\nTraining for {args.epochs} epochs, lr={args.lr}, batch_size={args.batch_size}")
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
    print(f"\nSaving LoRA adapter to {final_dir}...")
    model.save_pretrained(final_dir)
    tokenizer.save_pretrained(final_dir)

    # Merge LoRA into base model
    merged_dir = OUTPUT_DIR / "merged"
    print(f"Merging LoRA into base model at {merged_dir}...")
    model.save_pretrained_merged(merged_dir, tokenizer)

    print(f"\nTraining complete!")
    print(f"   Merged model: {merged_dir}")
    print(f"\n   Next: Export to ONNX with optimum")


if __name__ == "__main__":
    main()
