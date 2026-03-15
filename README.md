# The Agentic Crew

Source for *The Agentic Crew* — a book about how software engineers learn to build with AI agents. Written in [Typst](https://typst.app/), with a companion website built in [Astro](https://astro.build/).

**Live site:** [theagenticcrew.com](https://theagenticcrew.com)

## Prerequisites

- [Typst](https://typst.app/) — for compiling the book to PDF
- [just](https://github.com/casey/just) — command runner
- [Node.js](https://nodejs.org/) — for the website

## Quick start

```bash
# Build the book to PDF
just build

# Watch for changes and rebuild automatically
just watch

# Build and open the PDF (macOS)
just open
```

## Useful commands

| Command | Description |
|---------|-------------|
| `just build` | Compile the book to PDF |
| `just watch` | Watch for changes and rebuild automatically |
| `just open` | Build and open the PDF |
| `just new-chapter <name>` | Scaffold a new chapter file |
| `just site` | Start the website dev server |
| `just site-build` | Build the website for production |
| `just deploy` | Build and deploy the website to production |
| `just wc` | Show approximate word count |
| `just clean` | Remove build artifacts |

## Project structure

```
book.typ              # Main entry point — title page, foreword, chapter includes
chapters/             # Individual chapter files (.typ)
assets/               # Images and figures
website/              # Astro website (theagenticcrew.com)
build/                # Compiled PDF output
```
