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
  #text(size: 13pt, fill: luma(80))[How software engineers learn to build with agents]
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

I've been a software engineer for a long time. I know what it feels like to have a codebase in your head — to open an editor, navigate to the right file, and just _write_ the thing. That muscle memory, built over years of keystrokes and debugging sessions, is real. It's earned.

And now the ground is shifting under our feet.

AI agents can write code, run tests, refactor modules, and ship pull requests. Not perfectly — but well enough that ignoring them is no longer an option. For engineers like us, this raises an uncomfortable question: if the machine can do what I do, what's left for me?

This book is my answer. The craft isn't dying — it's evolving. We're moving from writing every line by hand to something more like directing, orchestrating, and collaborating. Less typing, more thinking. Less editor, more engineering. The skills that got us here — systems thinking, taste, judgement, knowing what to build and why — those matter _more_ now, not less.

But the transition is messy. I wrote this book because I'm living it, and I know you are too.

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
