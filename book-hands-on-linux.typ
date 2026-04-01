// The Agentic Crew — Hands-On Guide (Linux Edition)
// Practical exercises for learning by doing
// Compiles all chapters into a single PDF — Linux-specific instructions only

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")


#set document(
  title: "The Agentic Crew: Hands-On Guide — Linux Edition",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[The Agentic Crew: Hands-On Guide]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.7em,
)

#set heading(numbering: none)

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1.5em)
  set text(size: 22pt, weight: "bold")
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  v(1em)
  set text(size: 14pt, weight: "bold")
  it
  v(0.5em)
}

// ─── Cover Page ───

#page(margin: 0pt, header: none)[
  #let white  = rgb("#f5f0e8")
  #let cream  = rgb("#e8dfc8")
  #let red    = rgb("#d42b2b")

  #block(width: 100%, height: 100%, fill: black)[

    // ── Full-bleed Bauhaus background — no overlays, no gradients ──
    #place(dx: 0%, dy: 0%)[
      #image(
        "assets/illustrations/hands-on-cover-fullbleed.jpg",
        width: 100%,
        height: 100%,
        fit: "cover",
      )
    ]

    // ── Eyebrow — sits in the natural black band at top ──
    #place(dx: 8%, dy: 4%)[
      #text(size: 7pt, fill: cream, weight: "bold", tracking: 4pt)[LEARN BY DOING]
    ]

    // ── Title ──
    #place(dx: 8%, dy: 9%)[
      #block(width: 84%)[
        #text(
          size: 34pt,
          weight: "bold",
          fill: white,
          font: "New Computer Modern",
          tracking: -0.6pt,
        )[The Agentic Crew]
      ]
    ]

    // ── Subtitle — sits in the natural black band at bottom ──
    #place(dx: 8%, dy: 76%)[
      #text(size: 11pt, fill: cream, style: "italic")[Hands-On Guide — Linux Edition]
    ]

    // ── Thin red accent line — Bauhaus loves a rule ──
    #place(dx: 8%, dy: 83%)[
      #line(length: 84%, stroke: 1.5pt + red)
    ]

    // ── Author ──
    #place(dx: 8%, dy: 87%)[
      #text(size: 10.5pt, fill: white)[Rasmus Bornhøft Schlünsen]
    ]

    // ── Date & revision ──
    #place(dx: 8%, dy: 94%)[
      #text(size: 7pt, fill: cream.transparentize(30%))[March 2026]
    ]
    #place(dx: 0%, dy: 94%)[
      #h(1fr)
      #text(size: 6pt, fill: cream.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── A Note Before We Start ───

#heading(outlined: false, numbering: none)[A Note Before We Start]

This book is the practical companion to _The Agentic Crew_. Where the main book explains the ideas, this one puts them into practice.

Each chapter is an exercise. You'll set up real tools, work with real repositories, and build real things — starting from scratch. The exercises are written for Linux (Ubuntu-based examples — adapt for your distribution).

You don't need to be a programmer. You do need to be willing to type commands into a terminal and see what happens. That's how you learn this stuff — not by reading about it, but by doing it.

By the end of this book, you'll have a working development environment, hands-on experience with Git and GitHub, and the confidence to collaborate on real projects using AI agents as your co-pilot.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _March 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Exercises", indent: 1.5em, depth: 1)

// ─── Chapters ───

#include "chapters/hands-on/01-setting-up-your-workstation.typ"
#include "chapters/hands-on/02-your-first-pull-request.typ"
#include "chapters/hands-on/03-your-first-ai-project.typ"

#include "chapters/hands-on/04-pair-programming-with-an-agent.typ"
#include "chapters/hands-on/05-going-live.typ"
#include "chapters/hands-on/06-pentesting-with-an-agent.typ"

// Future chapters:
// #include "chapters/hands-on/06-prompts-that-work.typ"
// #include "chapters/hands-on/06-building-from-scratch.typ"
// #include "chapters/hands-on/07-adding-guardrails.typ"
// #include "chapters/hands-on/08-multi-agent-workflows.typ"
// #include "chapters/hands-on/09-cicd-with-agents.typ"
// #include "chapters/hands-on/10-capstone-project.typ"

// ─── Dedication ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    The best way to learn \
    is to ship something real. \
    This book is your first commit.
  ]
]
