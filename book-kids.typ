// The Agentic Crew — A Kids' Guide
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "The Agentic Crew: A Kids' Guide",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[The Agentic Crew: A Kids' Guide]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.8em,
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
  #let bg = rgb("#0a0e1a")
  #let gold = rgb("#c9a84c")
  #let gold-light = rgb("#e0c878")
  #let gold-dim = rgb("#6b5a2e")
  #let cream = rgb("#f0ead6")
  #let navy = rgb("#1a2040")
  #let sky-blue = rgb("#4a90d9")

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Cover illustration
    #place(dx: 15%, dy: 25%)[
      #image("assets/kids/cover.jpg", width: 70%)
    ]

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 4pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 5%)[
      #text(size: 8pt, fill: gold, weight: "bold", tracking: 3pt)[FOR YOUNG CAPTAINS]
    ]

    // Title
    #place(dx: 8%, dy: 10%)[
      #block(width: 84%)[
        #text(
          size: 30pt,
          weight: "bold",
          fill: cream,
          font: "New Computer Modern",
          tracking: -0.4pt,
        )[The Agentic Crew]
      ]
    ]

    // Subtitle
    #place(dx: 8%, dy: 20%)[
      #text(
        size: 12pt,
        fill: gold-light,
        style: "italic",
      )[A Kids' Guide]
    ]

    // Separator
    #place(dx: 8%, dy: 82%)[
      #line(length: 84%, stroke: 0.4pt + gold-dim)
    ]

    // Author
    #place(dx: 8%, dy: 86%)[
      #text(
        size: 10.5pt,
        fill: cream.transparentize(25%),
      )[Rasmus Bornhoft Schlunsen]
    ]

    // Date & revision
    #place(dx: 8%, dy: 93%)[
      #text(size: 7.5pt, fill: gold-dim)[March 2026]
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── For Grown-Ups ───

#heading(outlined: false, numbering: none)[A Note for Grown-Ups]

This book is a companion to _The Agentic Crew: Engineering in the Age of AI Agents_. That book was written for software engineers. This one is written for their kids — and for any curious nine-year-old who wants to understand what all the fuss is about.

The ideas are real. We have simplified them, but we have not watered them down. Your child will learn what an AI agent actually is, why it needs rules, how to check its work, and when it is better to do things yourself. These are the same lessons their parents are learning at work — just told through ships, robots, and the occasional exploding sandwich.

If your child finishes this book and says, "I want to try giving a computer instructions," — mission accomplished.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _March 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "What's Inside", indent: 1.5em, depth: 1)

// ─── Chapters ───

#include "chapters/kids/00-prologue.typ"
#include "chapters/kids/01-welcome-aboard.typ"
#include "chapters/kids/02-meet-the-crew.typ"
#include "chapters/kids/03-the-ships-rules.typ"
#include "chapters/kids/04-the-captains-checklist.typ"
#include "chapters/kids/05-how-to-give-good-orders.typ"
#include "chapters/kids/06-when-things-go-wrong.typ"
#include "chapters/kids/07-knowing-when-to-do-it-yourself.typ"
#include "chapters/kids/08-captain-of-a-fleet.typ"
#include "chapters/kids/09-epilogue.typ"

// ─── Dedication ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    To my kids — \
    you are the best crew I have ever had. \
    This whole thing was for you. \
    Always.
  ]
]
