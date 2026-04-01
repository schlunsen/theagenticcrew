#!/usr/bin/env node
/**
 * Build-time script: chunks all 3 books into JSON for the in-browser RAG pipeline.
 * The embeddings are computed client-side (Transformers.js), but the chunking
 * and text extraction happen here at build time to keep the client lightweight.
 *
 * Output: website/public/book-chunks.json
 */

import { readFileSync, writeFileSync, readdirSync } from 'fs';
import { join, basename } from 'path';

const CHAPTERS_DIR = join(import.meta.dirname, '../../chapters');
const OUTPUT_PATH = join(import.meta.dirname, '../public/book-chunks.json');

const CHUNK_SIZE = 500;    // characters per chunk
const CHUNK_OVERLAP = 80;  // overlap between chunks for continuity

// ── Book definitions ──
const BOOKS = [
  {
    id: 'engineering',
    title: 'The Agentic Crew — Engineering Guide',
    dir: CHAPTERS_DIR,
    pattern: /^\d{2}-.*\.typ$/,   // 01-introduction.typ etc (no language suffix)
    exclude: /-(?:ca|es|da)\.typ$/,
  },
  {
    id: 'crew',
    title: 'The Agentic Crew — Crew Member\'s Guide',
    dir: join(CHAPTERS_DIR, 'crew'),
    pattern: /^\d{2}-.*\.typ$/,
    exclude: /-(?:ca|es|da)\.typ$/,
  },
  {
    id: 'hands-on',
    title: 'The Agentic Crew — Hands-On Guide',
    dir: join(CHAPTERS_DIR, 'hands-on'),
    pattern: /^\d{2}-.*\.typ$/,
    exclude: /-(?:ca|es|da)\.typ$/,
  },
];

// ── Typst cleanup ──
function cleanTypst(raw) {
  return raw
    // Remove Typst commands like #chapter(), #import, #figure, etc.
    .replace(/^#(?:import|include|set|show|let|figure|image|table|grid|columns|align|pagebreak|v\(|h\().*$/gm, '')
    // Convert #chapter("Title") or = Title to readable headings
    .replace(/#chapter\("([^"]+)"\)/g, '\n## $1\n')
    .replace(/^(=+)\s+(.+)$/gm, (_, level, title) => `\n${'#'.repeat(level.length + 1)} ${title}\n`)
    // Remove #emph[], #strong[], #text[], keeping content
    .replace(/#(?:emph|strong|text)\[([^\]]*)\]/g, '$1')
    // Remove #link() syntax
    .replace(/#link\("[^"]*"\)\[([^\]]*)\]/g, '$1')
    // Remove remaining # commands but keep content in brackets
    .replace(/#\w+\[([^\]]*)\]/g, '$1')
    // Remove standalone # commands
    .replace(/^#\w+.*$/gm, '')
    // Clean up Typst formatting
    .replace(/\*([^*]+)\*/g, '$1')   // bold
    .replace(/_([^_]+)_/g, '$1')     // italic
    .replace(/`([^`]+)`/g, '$1')     // inline code
    // Remove code blocks (```...```)
    .replace(/```[\s\S]*?```/g, '[code example]')
    // Collapse multiple blank lines
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

// ── Chunking ──
function chunkText(text, chunkSize, overlap) {
  const chunks = [];
  let start = 0;

  while (start < text.length) {
    let end = start + chunkSize;

    // Try to break at a sentence or paragraph boundary
    if (end < text.length) {
      const slice = text.slice(start, end + 100); // look ahead a bit
      const breakPoints = [
        slice.lastIndexOf('\n\n'),
        slice.lastIndexOf('. '),
        slice.lastIndexOf('.\n'),
        slice.lastIndexOf('? '),
        slice.lastIndexOf('! '),
      ].filter(i => i > chunkSize * 0.5); // only break after 50% of chunk

      if (breakPoints.length > 0) {
        end = start + Math.max(...breakPoints) + 1;
      }
    }

    const chunk = text.slice(start, end).trim();
    if (chunk.length > 50) { // skip tiny trailing chunks
      chunks.push(chunk);
    }

    start = end - overlap;
  }

  return chunks;
}

// ── Extract chapter title from filename ──
function chapterTitle(filename) {
  return basename(filename, '.typ')
    .replace(/^\d+-/, '')
    .replace(/-/g, ' ')
    .replace(/\b\w/g, c => c.toUpperCase());
}

// ── Main ──
const allChunks = [];
let totalChunks = 0;
let totalChars = 0;

for (const book of BOOKS) {
  let files;
  try {
    files = readdirSync(book.dir)
      .filter(f => book.pattern.test(f) && (!book.exclude || !book.exclude.test(f)))
      .sort();
  } catch (e) {
    console.warn(`  ⚠ Skipping ${book.id}: ${e.message}`);
    continue;
  }

  console.log(`📚 ${book.title} — ${files.length} chapters`);

  for (const file of files) {
    const raw = readFileSync(join(book.dir, file), 'utf-8');
    const cleaned = cleanTypst(raw);
    const chapter = chapterTitle(file);
    const chunks = chunkText(cleaned, CHUNK_SIZE, CHUNK_OVERLAP);

    for (let i = 0; i < chunks.length; i++) {
      allChunks.push({
        id: `${book.id}/${file}/${i}`,
        book: book.title,
        chapter,
        text: chunks[i],
      });
    }

    totalChars += cleaned.length;
    totalChunks += chunks.length;
    console.log(`  ✓ ${chapter}: ${chunks.length} chunks`);
  }
}

// Write output
const output = {
  version: 1,
  generated: new Date().toISOString(),
  stats: {
    books: BOOKS.length,
    chunks: totalChunks,
    totalChars,
  },
  chunks: allChunks,
};

writeFileSync(OUTPUT_PATH, JSON.stringify(output));

const sizeMB = (Buffer.byteLength(JSON.stringify(output)) / 1024 / 1024).toFixed(2);
console.log(`\n✅ Generated ${totalChunks} chunks from ${totalChars.toLocaleString()} chars`);
console.log(`📦 Output: ${OUTPUT_PATH} (${sizeMB} MB)`);
