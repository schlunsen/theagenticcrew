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

// ─── Title Page ───

#align(center + horizon)[
  #text(size: 28pt, weight: "bold")[The Agentic Crew]
  #v(0.8em)
  #text(size: 13pt, fill: luma(80))[A field guide to engineering in the age of AI agents]
  #v(2.5em)
  #text(size: 12pt)[Rasmus Bornhøft Schlünsen]
  #v(0.8em)
  #text(size: 10pt, fill: luma(120))[Draft — March 2026]
  #v(2em)
  #text(size: 11pt, weight: "bold")[€25]
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
#include "chapters/13-war-stories.typ"
#include "chapters/14-when-not-to-use-agents.typ"
#include "chapters/15-agentic-teams.typ"
#include "chapters/16-final-words.typ"
