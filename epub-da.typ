// Det Agentiske Mandskab — EPUB source
// Stripped of PDF-only features (page layout, headers, counters)

#set document(
  title: "Det Agentiske Mandskab",
  author: "Rasmus Bornhøft Schlünsen",
)

#set text(lang: "da")
#set heading(numbering: "1.1")

// ─── Title ───

= Det Agentiske Mandskab

_Hvordan softwareingeniører lærer at bygge med agenter_

Rasmus Bornhøft Schlünsen

Udkast — Marts 2026

// ─── Dedication ───

_Til mine børn — I er det bedste mandskab, jeg nogensinde har haft. Det hele var for jer. Altid._

// ─── Foreword ───

== Forord

Jeg har været softwareingeniør i lang tid. Jeg ved, hvordan det føles at have en codebase i hovedet — at åbne en editor, navigere til den rigtige fil og bare _skrive_ tingen. Den muskelhukommelse, bygget op over års tastetryk og debugging-sessioner, er ægte. Den er fortjent.

Og nu rykker jorden sig under vores fødder.

AI-agenter kan skrive kode, køre tests, refaktorere moduler og sende pull requests. Ikke perfekt — men godt nok til, at det ikke længere er en mulighed at ignorere dem. For ingeniører som os rejser det et ubehageligt spørgsmål: hvis maskinen kan gøre det, jeg gør, hvad er der så tilbage til mig?

Denne bog er mit svar. Håndværket er ikke ved at dø — det udvikler sig. Vi bevæger os fra at skrive hver linje i hånden til noget, der mere ligner at dirigere, orkestrere og samarbejde. Mindre tastning, mere tænkning. Mindre editor, mere ingeniørkunst. De evner, der bragte os hertil — systemtænkning, smag, dømmekraft, at vide hvad man skal bygge og hvorfor — de betyder _mere_ nu, ikke mindre.

Men overgangen er rodet. Jeg skrev denne bog, fordi jeg lever midt i det, og jeg ved, at du også gør.

_Rasmus Bornhøft Schlünsen — Marts 2026_

// ─── Chapters ───

#include "chapters/da/01-introduction.typ"
#include "chapters/da/02-context.typ"
#include "chapters/da/03-what-is-an-agent.typ"
#include "chapters/da/04-clovr-code-terminal.typ"
#include "chapters/da/05-guardrails.typ"
#include "chapters/da/06-git.typ"
#include "chapters/da/07-sandboxes.typ"
#include "chapters/da/08-testing-as-the-feedback-loop.typ"
#include "chapters/da/09-convention-over-configuration.typ"
#include "chapters/da/10-local-vs-commercial-llms.typ"
#include "chapters/da/11-prompting-as-engineering.typ"
#include "chapters/da/12-multi-agent-orchestration.typ"
#include "chapters/da/13-war-stories.typ"
#include "chapters/da/14-when-not-to-use-agents.typ"
#include "chapters/da/15-agentic-teams.typ"
#include "chapters/da/16-final-words.typ"
