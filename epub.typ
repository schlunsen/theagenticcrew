// The Agentic Crew — EPUB source
// Stripped of PDF-only features (page layout, headers, counters)

#set document(
  title: "The Agentic Crew",
  author: "Rasmus Bornhøft Schlünsen",
)

#set text(lang: "en")
#set heading(numbering: "1.1")

// ─── Title ───

= The Agentic Crew

_How software engineers learn to build with agents_

Rasmus Bornhøft Schlünsen

Draft — March 2026

// ─── Dedication ───

_To my kids — you're the best crew I've ever had. This whole thing was for you. Always._

// ─── Foreword ───

== Foreword

I've been a software engineer for a long time. I know what it feels like to have a codebase in your head — to open an editor, navigate to the right file, and just _write_ the thing. That muscle memory, built over years of keystrokes and debugging sessions, is real. It's earned.

And now the ground is shifting under our feet.

AI agents can write code, run tests, refactor modules, and ship pull requests. Not perfectly — but well enough that ignoring them is no longer an option. For engineers like us, this raises an uncomfortable question: if the machine can do what I do, what's left for me?

This book is my answer. The craft isn't dying — it's evolving. We're moving from writing every line by hand to something more like directing, orchestrating, and collaborating. Less typing, more thinking. Less editor, more engineering. The skills that got us here — systems thinking, taste, judgement, knowing what to build and why — those matter _more_ now, not less.

But the transition is messy. I wrote this book because I'm living it, and I know you are too.

_Rasmus Bornhøft Schlünsen — March 2026_

// ─── Chapters ───

#include "chapters/01-introduction.typ"
#include "chapters/02-context.typ"
#include "chapters/03-what-is-an-agent.typ"
#include "chapters/04-guardrails.typ"
#include "chapters/05-git.typ"
#include "chapters/06-sandboxes.typ"
#include "chapters/07-testing-as-the-feedback-loop.typ"
#include "chapters/08-convention-over-configuration.typ"
#include "chapters/09-tool-integrations.typ"
#include "chapters/10-local-vs-commercial-llms.typ"
#include "chapters/11-prompting-as-engineering.typ"
#include "chapters/12-multi-agent-orchestration.typ"
#include "chapters/13-cicd-and-agents.typ"
#include "chapters/14-war-stories.typ"
#include "chapters/15-agents-as-pentesters.typ"
#include "chapters/16-when-not-to-use-agents.typ"
#include "chapters/17-agentic-teams.typ"
#include "chapters/18-final-words.typ"
