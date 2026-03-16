// The Agentic Crew
// Main entry point — compiles all chapters into a single PDF

#set document(
  title: "The Agentic Crew",
  author: "Rasmus Bornhøft Schlünsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.75in, bottom: 0.75in, left: 0.7in, right: 0.7in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[The Agentic Crew]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 10pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.65em,
)

#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(2em)
  set text(size: 20pt, weight: "bold")
  it
  v(1em)
}

#show heading.where(level: 2): it => {
  v(1.2em)
  set text(size: 13pt, weight: "bold")
  it
  v(0.6em)
}

// ─── Cover Page ───

#page(margin: 0pt, header: none)[
  #let bg = rgb("#0a0e1a")
  #let gold = rgb("#c9a84c")
  #let gold-light = rgb("#e0c878")
  #let gold-dim = rgb("#6b5a2e")
  #let cream = rgb("#f0ead6")
  #let navy = rgb("#1a2040")

  // Ship's wheel (helm) drawn with Typst primitives
  #let helm(cx, cy, outer-r, spoke-count: 8, col: gold) = {
    // Outer ring
    place(dx: cx - outer-r, dy: cy - outer-r)[
      #circle(radius: outer-r, stroke: 2pt + col)
    ]
    // Inner ring
    place(dx: cx - outer-r * 0.55, dy: cy - outer-r * 0.55)[
      #circle(radius: outer-r * 0.55, stroke: 1.2pt + col)
    ]
    // Centre hub
    place(dx: cx - outer-r * 0.12, dy: cy - outer-r * 0.12)[
      #circle(radius: outer-r * 0.12, fill: col)
    ]
    // Spokes
    for i in range(spoke-count) {
      let angle = i * 360deg / spoke-count
      let spoke-len = outer-r * 2
      place(dx: cx, dy: cy)[
        #line(length: spoke-len, angle: angle, stroke: 1.5pt + col)
      ]
    }
    // Handle pegs at end of each spoke (small circles)
    for i in range(spoke-count) {
      let angle = i * 360deg / spoke-count
      let peg-x = cx + outer-r * 1.15 * calc.cos(angle) - 3.5pt
      let peg-y = cy + outer-r * 1.15 * calc.sin(angle) - 3.5pt
      place(dx: peg-x, dy: peg-y)[
        #circle(radius: 3.5pt, fill: col)
      ]
    }
  }

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Ship's wheel — centred, large, slightly faded
    #helm(52%, 42%, 55pt, col: gold.transparentize(25%))

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 3.5pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 8%)[
      #text(size: 7.5pt, fill: gold, weight: "bold", tracking: 3pt)[A FIELD GUIDE]
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

    // Subtitle — below the wheel
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          size: 11pt,
          fill: gold-light.transparentize(20%),
          style: "italic",
        )[Engineering in the age of AI agents]
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

    // Date
    #place(dx: 8%, dy: 93%)[
      #text(size: 7.5pt, fill: gold-dim)[March 2026]
    ]
  ]
]

#pagebreak()

// ─── Dedication ───

#align(center + horizon)[
  #text(size: 12pt, style: "italic")[
    For my beloved children. \
    You are my crew.
  ]
]

#pagebreak()

// ─── Foreword ───

#heading(outlined: false, numbering: none)[Foreword]

It was a Tuesday evening, sometime last year. My kids were asleep, and I was staring at a migration script I'd been dreading all week — the kind of tedious, table-by-table reshuffling that eats an entire day if you're careful, and destroys production if you're not. On a whim, I described the problem to an agent. Schema here, constraints there, watch out for this foreign key. Then I hit enter and went to make tea.

When I came back, the script was done. Not a rough draft. _Done._ Correct edge cases, rollback logic, comments I would have written myself. I sat there for a long time, tea going cold, feeling two things at once: genuine awe — and a quiet, creeping dread.

Because that migration? That was _my_ thing. I was the person on the team who could hold the whole schema in my head, who knew which joins were cursed, who could write the careful SQL by hand. Fifteen years of muscle memory, and an LLM had just matched it in four minutes while I boiled water.

I want to be honest with you: I didn't sleep well that night. I lay in bed running the same loop every engineer I know has run. _What am I for now? What happens to the craft I spent half my life building? Am I training my replacement?_

It took me months — and a lot of building, failing, and rebuilding with these tools — to find the answer. And the answer surprised me. The craft isn't dying. It's _molting._ The outer shell — the keystrokes, the syntax, the boilerplate — that part is falling away. But the animal underneath? The part that knows _what_ to build and _why_, that smells a bad abstraction from three files away, that can hold a whole system in mind and feel where it's fragile? That part is more alive than ever.

We're not being replaced. We're being promoted. From typists to thinkers. From writing code to directing it — orchestrating, reviewing, shaping. The skills that made you a good engineer — systems thinking, taste, judgement, the instinct for simplicity — those are the _whole game_ now, not just the background hum.

But nobody gave us a manual for this transition. It's messy and uncomfortable and sometimes humbling. I wrote this book because I'm living through it, and I have a feeling you are too. These pages are everything I've learned about working _with_ the agents instead of against them — or worse, pretending they don't exist.

If you've ever watched an AI write code that looked like yours and felt your stomach drop, this book is for you. Keep reading. It gets better — and stranger — than you think.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _March 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Contents", indent: 1.5em, depth: 2)

// ─── Chapters ───

#include "chapters/01-introduction.typ"
#include "chapters/02-context.typ"
#include "chapters/03-what-is-an-agent.typ"
#include "chapters/04-clovr-code-terminal.typ"
#include "chapters/05-guardrails.typ"
#include "chapters/06-git.typ"
#include "chapters/07-sandboxes.typ"
#include "chapters/08-testing-as-the-feedback-loop.typ"
#include "chapters/09-convention-over-configuration.typ"
#include "chapters/10-local-vs-commercial-llms.typ"
#include "chapters/11-prompting-as-engineering.typ"
#include "chapters/12-multi-agent-orchestration.typ"
#include "chapters/12b-cicd-and-agents.typ"
#include "chapters/13-war-stories.typ"
#include "chapters/14-when-not-to-use-agents.typ"
#include "chapters/15-agentic-teams.typ"
#include "chapters/16-final-words.typ"

// ─── Dedication (End) ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    To my beloved children — \
    every page of this book was written \
    with you in my heart. \
    You are my reason, my crew, my everything.
  ]
]
