// The Agentic Crew — Crew Member's Guide
// For tech-savvy people who don't write code
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "The Agentic Crew: Crew Member's Guide",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[The Agentic Crew: Crew Member's Guide]
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
  #let bg = rgb("#0a0e1a")
  #let gold = rgb("#c9a84c")
  #let gold-light = rgb("#e0c878")
  #let gold-dim = rgb("#6b5a2e")
  #let cream = rgb("#f0ead6")
  #let navy = rgb("#1a2040")

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Compass rose illustration — centred, large
    #place(dx: 18%, dy: 30%)[
      #block(width: 64%, clip: true)[
        #set image(width: 100%)
        #image("assets/illustrations/crew/cover-compass.jpg")
      ]
    ]

    // Semi-transparent overlay to blend compass into background
    #place(dx: 0%, dy: 30%)[
      #rect(width: 100%, height: 45%, fill: bg.transparentize(40%))
    ]

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 3.5pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 8%)[
      #text(size: 7.5pt, fill: gold, weight: "bold", tracking: 3pt)[FOR THE WHOLE CREW]
    ]

    // Title
    #place(dx: 8%, dy: 14%)[
      #block(width: 84%)[
        #text(
          size: 34pt,
          weight: "bold",
          fill: cream,
          font: "New Computer Modern",
          tracking: -0.6pt,
        )[The Agentic Crew]
      ]
    ]

    // Subtitle — below title
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          size: 11pt,
          fill: gold-light.transparentize(20%),
          style: "italic",
        )[Crew Member's Guide]
      ]
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
      )[Rasmus Bornhøft Schlünsen]
    ]

    // Date & revision
    #place(dx: 8%, dy: 93%)[
      #text(size: 7.5pt, fill: gold-dim)[March 2026]
      #h(1fr)
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── A Note Before We Start ───

#heading(outlined: false, numbering: none)[A Note Before We Start]

This book is a companion to _The Agentic Crew: Engineering in the Age of AI Agents_. That book was written for software engineers — people who write code for a living. This one is for everyone else who's good with computers.

You might be a project manager, a designer, a sysadmin, a data analyst, a small business owner, or just the person in your family who fixes the Wi-Fi. You live in spreadsheets, manage inboxes like a general, and have forty-seven browser tabs open right now. But you've never written a line of code — and you don't need to.

AI agents are changing how software gets built. That affects you, whether you're working alongside developers, running a business that depends on software, or just trying to understand what's happening to the world around you. The ideas in this book are real. We've simplified the technical details, but we haven't watered them down.

By the end, you'll understand what agents actually are, how modern software works under the hood, and — most importantly — how to direct an agent to build something real. No programming required.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _March 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "What's Inside", indent: 1.5em, depth: 1)

// ─── Chapters ───

#include "chapters/crew/01-welcome-to-the-crew.typ"
#include "chapters/crew/02-the-ground-is-shifting.typ"
#include "chapters/crew/03-whats-under-the-hood.typ"
#include "chapters/crew/04-what-is-an-agent.typ"
#include "chapters/crew/05-how-to-give-good-instructions.typ"
#include "chapters/crew/06-what-the-agent-can-see.typ"
#include "chapters/crew/07-the-trust-gradient.typ"
#include "chapters/crew/08-extending-the-crews-reach.typ"
#include "chapters/crew/11-building-something-real.typ"
#include "chapters/crew/09-the-padlock.typ"
#include "chapters/crew/12-building-something-else.typ"
#include "chapters/crew/12-when-things-go-wrong.typ"
#include "chapters/crew/13-when-to-do-it-yourself.typ"
#include "chapters/crew/14-being-the-human-in-the-loop.typ"
#include "chapters/crew/15-talking-to-your-tech-team.typ"
#include "chapters/crew/16-keeping-your-finger-on-the-pulse.typ"
#include "chapters/crew/18-getting-started.typ"
#include "chapters/crew/17-final-words.typ"

// ─── Dedication ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    To everyone who was told \
    "you're not technical enough." \
    You are. You always were. \
    Now the tools agree.
  ]
]
