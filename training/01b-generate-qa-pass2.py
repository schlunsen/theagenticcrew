#!/usr/bin/env python3
"""
Pass 2: Generate additional training data — multi-turn conversations,
summaries, comparisons, and "explain simply" variants.
Appends to existing training_data.jsonl.

Usage: python 01b-generate-qa-pass2.py
"""

import os, re, json, subprocess, time
from pathlib import Path

_local_chapters = Path(__file__).parent.parent / "chapters"
_server_chapters = Path(__file__).parent
CHAPTERS_DIR = _local_chapters if _local_chapters.exists() and (_local_chapters / "01-introduction.typ").exists() else _server_chapters
OUTPUT_FILE = Path(__file__).parent / "training_data.jsonl"

BOOKS = [
    {"id": "engineering", "title": "The Agentic Crew — Engineering Guide",
     "dir": CHAPTERS_DIR, "pattern": r"^\d{2}-.*\.typ$", "exclude": r"-(?:ca|es|da)\.typ$"},
    {"id": "crew", "title": "The Agentic Crew — Crew Member's Guide",
     "dir": CHAPTERS_DIR / "crew", "pattern": r"^\d{2}-.*\.typ$", "exclude": r"-(?:ca|es|da)\.typ$"},
    {"id": "hands-on", "title": "The Agentic Crew — Hands-On Guide",
     "dir": CHAPTERS_DIR / "hands-on", "pattern": r"^\d{2}-.*\.typ$", "exclude": r"-(?:ca|es|da)\.typ$"},
]

POLLY_SYSTEM = (
    'You are Polly, a friendly pirate parrot AI assistant for "The Agentic Crew" '
    "books by Rasmus Schlunsen. Answer questions about the books warmly and accurately "
    "with occasional pirate flair. Cite specific chapters when relevant."
)

def clean_typst(raw):
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

def chapter_title(filename):
    return Path(filename).stem.split("-", 1)[-1].replace("-", " ").title() if "-" in Path(filename).stem else Path(filename).stem

def call_claude(prompt):
    try:
        result = subprocess.run(
            ["claude", "-p", prompt, "--output-format", "stream-json", "--model", "sonnet", "--max-turns", "1", "--verbose"],
            capture_output=True, text=True, timeout=180,
        )
        if result.returncode != 0:
            return ""
        text = ""
        for line in result.stdout.strip().split("\n"):
            if not line.strip(): continue
            try:
                event = json.loads(line)
                if event.get("type") == "assistant":
                    for block in event.get("message", {}).get("content", []):
                        if block.get("type") == "text":
                            text += block.get("text", "")
            except json.JSONDecodeError:
                continue
        return text.strip()
    except:
        return ""

MULTI_TURN_PROMPT = """Given this book section from "{book_title}", chapter "{chapter_name}":

---
{section_text}
---

Generate 2 MULTI-TURN conversations (2-3 exchanges each) where a user asks Polly (a pirate parrot AI assistant) about this content. The user should ask a follow-up question based on Polly's first answer.

Polly should:
- Answer based ONLY on the text above
- Be warm with occasional pirate flair (don't overdo it)
- Cite the book/chapter naturally
- Keep answers 2-4 sentences

Output as JSON array of conversations:
[
  {{"turns": [
    {{"role": "user", "content": "first question"}},
    {{"role": "assistant", "content": "Polly's answer"}},
    {{"role": "user", "content": "follow-up question"}},
    {{"role": "assistant", "content": "Polly's follow-up answer"}}
  ]}},
  ...
]

ONLY output the JSON array."""

SUMMARY_PROMPT = """Given this chapter text from "{book_title}", chapter "{chapter_name}":

---
{section_text}
---

Generate 3 Q&A pairs:
1. "What are the key takeaways from the {chapter_name} chapter?" -> comprehensive summary
2. "Can you explain {chapter_name} simply?" -> ELI5-style explanation
3. A "How does X compare to Y?" question based on contrasts in the text

Polly (pirate parrot AI) should answer warmly, cite the chapter, and be accurate.

Output as JSON array:
[{{"user": "question", "assistant": "answer"}}, ...]

ONLY output the JSON array."""

def main():
    existing = 0
    if OUTPUT_FILE.exists():
        with open(OUTPUT_FILE) as f:
            existing = sum(1 for _ in f)
    print(f"📂 Existing examples: {existing}")

    total_new = 0
    with open(OUTPUT_FILE, "a") as f:
        for book in BOOKS:
            book_dir = book["dir"]
            if not book_dir.exists():
                continue
            files = sorted([fn for fn in os.listdir(book_dir)
                          if re.match(book["pattern"], fn) and not re.search(book["exclude"], fn)])
            print(f"\n📚 {book['title']} — {len(files)} chapters", flush=True)

            for filename in files:
                filepath = book_dir / filename
                raw = filepath.read_text()
                cleaned = clean_typst(raw)
                chapter = chapter_title(filename)

                # Use full chapter text (truncated to 4000 chars)
                chapter_text = cleaned[:4000]

                # Multi-turn conversations
                prompt = MULTI_TURN_PROMPT.format(
                    book_title=book["title"], chapter_name=chapter, section_text=chapter_text)
                text = call_claude(prompt)
                convos = []
                try:
                    convos = json.loads(text)
                except:
                    match = re.search(r"\[.*\]", text or "", re.DOTALL)
                    if match:
                        try: convos = json.loads(match.group())
                        except: pass

                for convo in convos:
                    turns = convo.get("turns", [])
                    if len(turns) >= 4:
                        # 2-turn conversation
                        example = {"messages": [
                            {"role": "system", "content": POLLY_SYSTEM},
                            {"role": "user", "content": turns[0]["content"]},
                            {"role": "assistant", "content": turns[1]["content"]},
                            {"role": "user", "content": turns[2]["content"]},
                            {"role": "assistant", "content": turns[3]["content"]},
                        ]}
                        f.write(json.dumps(example) + "\n")
                        total_new += 1

                # Summary/comparison questions
                prompt = SUMMARY_PROMPT.format(
                    book_title=book["title"], chapter_name=chapter, section_text=chapter_text)
                text = call_claude(prompt)
                pairs = []
                try:
                    pairs = json.loads(text)
                except:
                    match = re.search(r"\[.*\]", text or "", re.DOTALL)
                    if match:
                        try: pairs = json.loads(match.group())
                        except: pass

                for pair in pairs:
                    example = {"messages": [
                        {"role": "system", "content": POLLY_SYSTEM},
                        {"role": "user", "content": pair["user"]},
                        {"role": "assistant", "content": pair["assistant"]},
                    ]}
                    f.write(json.dumps(example) + "\n")
                    total_new += 1

                f.flush()
                print(f"  ✓ {chapter}: {len(convos)} multi-turn + {len(pairs)} summary (new: {total_new})", flush=True)
                time.sleep(0.3)

    print(f"\n✅ Pass 2 complete! Added {total_new} examples")
    print(f"📦 Total: {existing + total_new} examples in {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
