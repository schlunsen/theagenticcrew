// The Agentic Crew
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#import "theme.typ": *
#show: book.with(revision: revision)

// ─── Cover Page ───

#page(margin: 0pt, header: none, footer: none)[
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
      #text(font: sans, size: 7pt, fill: gold, weight: 500, tracking: 3.2pt)[A FIELD GUIDE]
    ]

    // Title
    #place(dx: 8%, dy: 14%)[
      #block(width: 84%)[
        #text(
          size: 38pt,
          weight: 400,
          fill: cream,
          font: display,
          tracking: -0.8pt,
        )[The Agentic #text(style: "italic", weight: 300, fill: gold-light)[Crew]]
      ]
    ]

    // Subtitle — below the wheel
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          font: display,
          size: 12pt,
          weight: 300,
          fill: gold-light.transparentize(15%),
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
        font: display,
        size: 11pt,
        fill: cream.transparentize(20%),
      )[Rasmus Bornhøft Schlünsen]
    ]

    // Date & revision
    #place(dx: 8%, dy: 93%)[
      #text(font: sans, size: 6.5pt, tracking: 1.4pt, fill: gold)[SECOND EDITION · SEPTEMBER 2026]
      #h(1fr)
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(font: sans, size: 5.5pt, fill: gold-dim.transparentize(30%))[rev #revision]
      #h(8%)
    ]
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

#image("assets/illustrations/foreword-molting.jpg", width: 80%)

We're not being replaced. We're being promoted. From typists to thinkers. From writing code to directing it — orchestrating, reviewing, shaping. The skills that made you a good engineer — systems thinking, taste, judgement, the instinct for simplicity — those are the _whole game_ now, not just the background hum.

But nobody gave us a manual for this transition. It's messy and uncomfortable and sometimes humbling. I wrote this book because I'm living through it, and I have a feeling you are too. These pages are everything I've learned about working _with_ the agents instead of against them — or worse, pretending they don't exist.

If you've ever watched an AI write code that looked like yours and felt your stomach drop, this book is for you. Keep reading. It gets better — and stranger — than you think.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _March 2026_
]

#pagebreak()

// ─── Preface to the Second Edition ───

#heading(outlined: false, numbering: none)[Preface to the Second Edition]

The first edition of this book came out in March 2026. Six months later, I'm writing a second one. In most fields that would be embarrassing. In this one, it's overdue.

A lot moved in those six months. Agent instruction files converged on a shared standard. Skills turned the prompt library into something you can version, review, and load on demand. The "overnight agent" I described as a hand-rolled shell script became a product feature — you assign an issue, and a pull request comes back. Open-weight models closed much of the gap I described in the models chapter. And prompt injection went from a curiosity to a string of real, public incidents involving the exact integrations I'd cheerfully told you to set up.

Something moved for me, too. I spent most of those months _building_ agentic systems rather than just driving them — writing the loops, the tools, the handovers, and the guardrails myself. Sitting on the other side of the harness changed how I think about everything in this book. It made me a better user of agents, mostly by taking away the last of my surprise.

Here's what's new in this edition:

- *A new chapter on the agent attack surface* — prompt injection, poisoned tools, and supply-chain attacks, and how to limit the blast radius. This was the biggest gap in the first edition.
- *A new chapter on building your own agents* — for when you move from using a coding agent to shipping agents inside your own products and pipelines.
- *Context, conventions, and prompting updated* for how the field now works: context engineering, compaction, `AGENTS.md`, skills, hooks, and plan-first workflows.
- *The models chapter rewritten*, and the pipeline and orchestration chapters updated for cloud agents that do the work and send you a pull request.
- *A new appendix, "The State of the Tools"*, where I've moved the specific model names, prices, and product details that go out of date fastest. The chapters should age better as a result. The appendix won't — that's its job.
- *Corrections.* A few commands and examples in the first edition were wrong. For a book that warns you about hallucinated libraries, that stung. They're fixed.

What didn't change is the core of the book: context, guardrails, tests, conventions, and judgement. If anything, the last six months made me more confident that those are the parts that last. The tools keep changing. The ship is still the ship.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _September 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Contents", depth: 2)

// ─── Chapters ───

#part("I", [Setting Sail], [What changed, and what an agent really is.])
#include "chapters/01-introduction.typ"
#include "chapters/02-what-is-an-agent.typ"
#part("II", [Rigging the Ship], [The durable foundations — context, guardrails, git, tests, conventions, and memory.])
#include "chapters/03-context.typ"
#include "chapters/04-guardrails-trust-and-sandboxes.typ"
#include "chapters/05-git.typ"
#include "chapters/06-testing-as-the-feedback-loop.typ"
#include "chapters/07-convention-over-configuration.typ"
#include "chapters/08-the-ships-log.typ"
#part("III", [Beyond the Harbour], [Reach, risk, intent, and the models underneath.])
#include "chapters/09-extending-the-agents-reach.typ"
#include "chapters/09b-the-agent-attack-surface.typ"
#include "chapters/10-articulating-intent.typ"
#include "chapters/11-local-commercial-and-hybrid-models.typ"
#part("IV", [Running a Fleet], [Many agents, pipelines, and building your own.])
#include "chapters/12-multi-agent-orchestration.typ"
#include "chapters/13-agents-in-the-pipeline.typ"
#include "chapters/13b-building-your-own-agents.typ"
#part("V", [Hard-Won Lessons], [Failure, restraint, teams, and what lasts.])
#include "chapters/14-when-agents-get-it-wrong.typ"
#include "chapters/15-when-not-to-use-agents.typ"
#include "chapters/16-agentic-teams.typ"
#include "chapters/17-final-words.typ"

// ─── Appendices ───

#part("", [Appendices], [Two companions to the main text — one that pushes every principle to its limit, and one that is meant to go out of date.])

#appendix("A", [Agents as Pentesters])

#include "chapters/appendix-a-agents-as-pentesters.typ"

#appendix("B", [The State of the Tools (September 2026)])

#include "chapters/appendix-b-state-of-the-tools.typ"

// ─── Dedication (End) ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    To my kids — \
    you're the best crew I've ever had. \
    This whole thing was for you. \
    Always.
  ]
]
