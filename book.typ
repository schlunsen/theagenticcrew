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
  #let cover-bg = rgb("#0f0d2e")
  #let cover-accent = rgb("#6c63ff")
  #let cover-accent-light = rgb("#a8a3ff")
  #let cover-muted = rgb("#8888bb")

  #block(width: 100%, height: 100%, fill: cover-bg)[

    // Decorative circles — abstract "nodes" suggesting connected agents
    #place(dx: 72%, dy: 12%)[
      #circle(radius: 28pt, stroke: 0.6pt + cover-accent.lighten(60%).transparentize(70%))
    ]
    #place(dx: 80%, dy: 18%)[
      #circle(radius: 6pt, fill: cover-accent.transparentize(40%))
    ]
    #place(dx: 62%, dy: 8%)[
      #circle(radius: 4pt, fill: cover-accent-light.transparentize(50%))
    ]
    #place(dx: 85%, dy: 30%)[
      #circle(radius: 16pt, stroke: 0.4pt + cover-accent.transparentize(60%))
    ]
    #place(dx: 58%, dy: 22%)[
      #circle(radius: 10pt, stroke: 0.5pt + cover-accent-light.transparentize(65%))
    ]

    // Connecting lines between nodes
    #place(dx: 73%, dy: 15%)[
      #line(length: 45pt, angle: 35deg, stroke: 0.3pt + cover-accent.transparentize(70%))
    ]
    #place(dx: 82%, dy: 21%)[
      #line(length: 35pt, angle: 60deg, stroke: 0.3pt + cover-accent.transparentize(75%))
    ]
    #place(dx: 64%, dy: 11%)[
      #line(length: 50pt, angle: 20deg, stroke: 0.3pt + cover-accent.transparentize(70%))
    ]

    // Bottom decorative elements
    #place(dx: 8%, dy: 78%)[
      #circle(radius: 20pt, stroke: 0.5pt + cover-accent.transparentize(75%))
    ]
    #place(dx: 15%, dy: 85%)[
      #circle(radius: 5pt, fill: cover-accent.transparentize(60%))
    ]
    #place(dx: 22%, dy: 82%)[
      #circle(radius: 12pt, stroke: 0.4pt + cover-accent-light.transparentize(70%))
    ]
    #place(dx: 12%, dy: 80%)[
      #line(length: 40pt, angle: -30deg, stroke: 0.3pt + cover-accent.transparentize(75%))
    ]

    // Accent bar
    #place(dx: 8%, dy: 35%)[
      #rect(width: 3pt, height: 80pt, fill: cover-accent)
    ]

    // Title block
    #place(dx: 8%, dy: 38%)[
      #block(width: 80%)[
        #text(
          size: 32pt,
          weight: "bold",
          fill: white,
          font: "New Computer Modern",
          tracking: -0.5pt,
        )[The Agentic\ Crew]

        #v(1em)

        #text(
          size: 11pt,
          fill: cover-muted,
          style: "italic",
        )[A field guide to engineering\ in the age of AI agents]
      ]
    ]

    // Horizontal rule
    #place(dx: 8%, dy: 72%)[
      #line(length: 84%, stroke: 0.4pt + cover-accent.transparentize(60%))
    ]

    // Author
    #place(dx: 8%, dy: 75%)[
      #text(
        size: 11pt,
        fill: cover-accent-light,
        weight: "regular",
      )[Rasmus Bornhøft Schlünsen]
    ]

    // Edition
    #place(dx: 8%, dy: 90%)[
      #text(
        size: 8pt,
        fill: cover-muted.transparentize(30%),
        weight: "regular",
      )[March 2026]
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
