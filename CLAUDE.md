# CLAUDE.md

## Project

The Agentic Crew — a book about agentic engineering by Rasmus Bornhøft Schlünsen. Built with Typst.

## Commands

```bash
just build    # Compile to PDF
just watch    # Auto-rebuild on changes
just open     # Build and open PDF
just wc       # Word count
```

## Structure

- `book.typ` — main file (title page, ToC, chapter includes)
- `chapters/*.typ` — one file per chapter
- `assets/` — images (screenshots, diagrams)
- `build/` — output PDFs

## Production Server

The book's website runs on theagenticcrew.com (deployment details kept outside repo).
