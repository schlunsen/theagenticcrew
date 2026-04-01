#!/usr/bin/env python3
"""
Step 1: Generate synthetic Q&A training data from book chapters using Claude CLI.

Reads all .typ chapter files, cleans them, splits into sections,
and uses `claude` CLI (Claude Code) to generate Q&A pairs for fine-tuning Polly.

Usage:
    python 01-generate-qa-data.py
"""

import os
import re
import json
import subprocess
import time
from pathlib import Path

# When running on server, chapters are in the same directory as this script
# When running locally, they're in ../chapters/
_local_chapters = Path(__file__).parent.parent / "chapters"
_server_chapters = Path(__file__).parent
CHAPTERS_DIR = _local_chapters if _local_chapters.exists() and (_local_chapters / "01-introduction.typ").exists() else _server_chapters
OUTPUT_FILE = Path(__file__).parent / "training_data.jsonl"

# Book definitions (English only)
BOOKS = [
    {
        "id": "engineering",
        "title": "The Agentic Crew — Engineering Guide",
        "dir": CHAPTERS_DIR,
        "pattern": r"^\d{2}-.*\.typ$",
        "exclude": r"-(?:ca|es|da)\.typ$",
    },
    {
        "id": "crew",
        "title": "The Agentic Crew — Crew Member's Guide",
        "dir": CHAPTERS_DIR / "crew",
        "pattern": r"^\d{2}-.*\.typ$",
        "exclude": r"-(?:ca|es|da)\.typ$",
    },
    {
        "id": "hands-on",
        "title": "The Agentic Crew — Hands-On Guide",
        "dir": CHAPTERS_DIR / "hands-on",
        "pattern": r"^\d{2}-.*\.typ$",
        "exclude": r"-(?:ca|es|da)\.typ$",
    },
]

POLLY_SYSTEM = (
    'You are Polly, a friendly pirate parrot AI assistant for "The Agentic Crew" '
    "books by Rasmus Schlunsen. Answer questions about the books warmly and accurately "
    "with occasional pirate flair. Cite specific chapters when relevant."
)


def clean_typst(raw: str) -> str:
    """Remove Typst markup, keep readable text."""
    text = raw
    text = re.sub(r"^#(?:import|include|set|show|let|figure|image|table|grid|columns|align|pagebreak|v\(|h\().*$", "", text, flags=re.MULTILINE)
    text = re.sub(r'#chapter\("([^"]+)"\)', r"\n## \1\n", text)
    text = re.sub(r"^(=+)\s+(.+)$", lambda m: f"\n{'#' * (len(m.group(1)) + 1)} {m.group(2)}\n", text, flags=re.MULTILINE)
    text = re.sub(r"#(?:emph|strong|text)\[([^\]]*)\]", r"\1", text)
    text = re.sub(r'#link\("[^"]*"\)\[([^\]]*)\]', r"\1", text)
    text = re.sub(r"#\w+\[([^\]]*)\]", r"\1", text)
    text = re.sub(r"^#\w+.*$", "", text, flags=re.MULTILINE)
    text = re.sub(r"```[\s\S]*?```", "[code example]", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def split_into_sections(text: str, chapter_name: str) -> list[dict]:
    """Split cleaned text into sections at heading boundaries."""
    sections = []
    # Split at markdown-style headings
    parts = re.split(r"\n(#{2,4}\s+.+)\n", text)

    current_heading = chapter_name
    current_text = ""

    for part in parts:
        if re.match(r"^#{2,4}\s+", part):
            # Save previous section if it has content
            if current_text.strip() and len(current_text.strip()) > 100:
                sections.append({"heading": current_heading, "text": current_text.strip()})
            current_heading = part.strip("# ").strip()
            current_text = ""
        else:
            current_text += part

    # Don't forget the last section
    if current_text.strip() and len(current_text.strip()) > 100:
        sections.append({"heading": current_heading, "text": current_text.strip()})

    # If no sections found, treat the whole chapter as one section
    if not sections and text.strip():
        sections.append({"heading": chapter_name, "text": text.strip()})

    return sections


def chapter_title(filename: str) -> str:
    """Convert filename to readable chapter title."""
    return (
        Path(filename).stem
        .split("-", 1)[-1] if "-" in Path(filename).stem else Path(filename).stem
    ).replace("-", " ").title()


GENERATION_PROMPT = """You are generating training data for a book Q&A chatbot called "Polly" — a friendly pirate parrot AI assistant.

Given this book section from "{book_title}", chapter "{chapter_name}", section "{section_heading}":

---
{section_text}
---

Generate {num_questions} diverse question-answer pairs. Include a mix of:
1. Factual questions about specific concepts in the text
2. "How do I..." practical questions
3. "What does the book say about..." questions
4. Comparison or opinion questions the text addresses
5. Questions a reader might naturally ask about this topic

For each answer, Polly should:
- Answer accurately based ONLY on the text provided
- Use a warm, helpful tone with occasional pirate/parrot personality (but don't overdo it)
- Naturally mention which book and chapter the information comes from
- Keep answers 2-5 sentences long
- Be specific — use details from the text, not generalities

Output as a JSON array:
[{{"user": "question here", "assistant": "Polly's answer here"}}, ...]

ONLY output the JSON array, nothing else."""

PERSONALITY_EXAMPLES = [
    {"user": "Hello!", "assistant": "Ahoy there, matey! I'm Polly, your AI parrot guide to The Agentic Crew books. Ask me anything about building AI agents, and I'll help you navigate these waters! What would you like to know? 🦜"},
    {"user": "Who are you?", "assistant": "I'm Polly — a cyberpunk pirate parrot who lives inside The Agentic Crew website! I've read all three books cover to cover: the Engineering Guide, the Crew Member's Guide, and the Hands-On Guide. I'm here to help you learn about building AI agents. What catches your eye?"},
    {"user": "What's the weather like?", "assistant": "Ha! Weather forecasting isn't quite in my wheelhouse, matey. But I can tell you everything about AI agents from The Agentic Crew books! Want to know about guardrails, multi-agent orchestration, or maybe how to build your first AI project?"},
    {"user": "How many books are there?", "assistant": "There are three books in The Agentic Crew series! The Engineering Guide (18 chapters on the technical deep-dive), the Crew Member's Guide (19 chapters for non-programmers), and the Hands-On Guide (3 practical chapters to get you building). All free! Which one interests you?"},
    {"user": "Who wrote these books?", "assistant": "The books were written by Rasmus Schlunsen! He created The Agentic Crew as a free guide born from the experience of porting the Claude Agent SDK using Claude Code. The Engineering Guide is the technical deep-dive, but there's also a Crew Member's Guide for folks who aren't programmers, and a Hands-On Guide for getting your hands dirty with real projects."},
    {"user": "What should I read first?", "assistant": "Depends on your background, matey! If you're a developer, start with the Engineering Guide — Chapter 1 (Introduction) sets the stage beautifully. If you're not a programmer but work with tech teams, the Crew Member's Guide is your treasure map. And if you just want to start building right away, the Hands-On Guide will have you shipping your first AI project in no time!"},
    {"user": "Can you write code for me?", "assistant": "I'm flattered, but code-writing isn't my specialty! I'm Polly — I know The Agentic Crew books inside and out and can help you understand concepts, point you to the right chapters, and explain how things work. For actual coding, the Hands-On Guide has step-by-step exercises. Want me to tell you what's covered there?"},
    {"user": "Is this book about ChatGPT?", "assistant": "Not specifically! The Agentic Crew focuses on AI agents — which are a step beyond simple chatbots like ChatGPT. The Engineering Guide's chapter on 'What Is An Agent' explains the difference brilliantly. Agents can use tools, make decisions, and take actions autonomously. ChatGPT is an LLM, but an agent is an LLM with superpowers! Want to dive deeper?"},
]


def generate_qa_pairs(book_title, chapter_name, section_heading, section_text):
    """Use Claude CLI to generate Q&A pairs for a section."""
    # Scale questions based on section length
    word_count = len(section_text.split())
    if word_count < 200:
        num_questions = 3
    elif word_count < 500:
        num_questions = 5
    else:
        num_questions = 7

    prompt = GENERATION_PROMPT.format(
        book_title=book_title,
        chapter_name=chapter_name,
        section_heading=section_heading,
        section_text=section_text[:4000],  # Cap to avoid token limits
        num_questions=num_questions,
    )

    try:
        result = subprocess.run(
            ["claude", "-p", prompt, "--output-format", "stream-json",
             "--model", "sonnet", "--max-turns", "1", "--verbose"],
            capture_output=True,
            text=True,
            timeout=180,
        )

        if result.returncode != 0:
            print(f"  ⚠ Claude CLI error for {section_heading}: {result.stderr[:200]}")
            return []

        # Extract assistant message content from stream-json output
        text = ""
        for line in result.stdout.strip().split("\n"):
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
                if event.get("type") == "assistant":
                    content = event.get("message", {}).get("content", [])
                    for block in content:
                        if block.get("type") == "text":
                            text += block.get("text", "")
            except json.JSONDecodeError:
                continue

        text = text.strip()
        if not text:
            print(f"  ⚠ Empty response for {section_heading}")
            return []

        # Try to parse JSON directly
        try:
            pairs = json.loads(text)
            return pairs
        except json.JSONDecodeError:
            pass

        # Try to extract JSON array from response
        match = re.search(r"\[.*\]", text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group())
            except json.JSONDecodeError:
                pass

        print(f"  ⚠ JSON parse error for {section_heading}")
        return []
    except subprocess.TimeoutExpired:
        print(f"  ⚠ Timeout for {section_heading}")
        return []
    except Exception as e:
        print(f"  ⚠ Error for {section_heading}: {e}")
        return []


def main():
    # Verify claude CLI is available
    try:
        subprocess.run(["claude", "--version"], capture_output=True, timeout=10)
    except FileNotFoundError:
        print("❌ `claude` CLI not found. Install Claude Code first.")
        return

    total_sections = 0
    total_examples = 0

    # Write incrementally so we can monitor progress
    with open(OUTPUT_FILE, "w") as f:
        # Write personality examples first
        print(f"🦜 Writing {len(PERSONALITY_EXAMPLES)} personality examples...")
        for pair in PERSONALITY_EXAMPLES:
            example = {
                "messages": [
                    {"role": "system", "content": POLLY_SYSTEM},
                    {"role": "user", "content": pair["user"]},
                    {"role": "assistant", "content": pair["assistant"]},
                ]
            }
            f.write(json.dumps(example) + "\n")
            total_examples += 1
        f.flush()

        for book in BOOKS:
            book_dir = book["dir"]
            if not book_dir.exists():
                print(f"⚠ Skipping {book['id']}: directory not found")
                continue

            files = sorted([
                fn for fn in os.listdir(book_dir)
                if re.match(book["pattern"], fn) and not re.search(book["exclude"], fn)
            ])

            print(f"\n📚 {book['title']} — {len(files)} chapters", flush=True)

            for filename in files:
                filepath = book_dir / filename
                raw = filepath.read_text()
                cleaned = clean_typst(raw)
                chapter = chapter_title(filename)
                sections = split_into_sections(cleaned, chapter)

                print(f"  📖 {chapter}: {len(sections)} sections", flush=True)

                for section in sections:
                    total_sections += 1
                    pairs = generate_qa_pairs(
                        book["title"],
                        chapter,
                        section["heading"],
                        section["text"],
                    )

                    for pair in pairs:
                        example = {
                            "messages": [
                                {"role": "system", "content": POLLY_SYSTEM},
                                {"role": "user", "content": pair["user"]},
                                {"role": "assistant", "content": pair["assistant"]},
                            ]
                        }
                        f.write(json.dumps(example) + "\n")
                        total_examples += 1
                    f.flush()

                    print(f"    ✓ {section['heading']}: {len(pairs)} Q&A pairs (total: {total_examples})", flush=True)

                    # Small delay to avoid rate limits
                    time.sleep(0.3)

    print(f"\n✅ Generated {total_examples} training examples from {total_sections} sections")
    print(f"📦 Output: {OUTPUT_FILE}")
    print(f"   Size: {OUTPUT_FILE.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    main()
