// La Tripulacio Agentica — Guia del Tripulant EPUB source
// Stripped of PDF-only features (page layout, headers, counters)

#set document(
  title: "La Tripulacio Agentica: Guia del Tripulant",
  author: "Rasmus Bornhoft Schlunsen",
)

#set text(lang: "ca")
#set heading(numbering: none)

// ─── Title ───

= La Tripulacio Agentica: Guia del Tripulant

_Per a persones amb coneixements tecnics que no escriuen codi._

Rasmus Bornhoft Schlunsen

Marc 2026

// ─── Una nota abans de comecar ───

== Una nota abans de comecar

Aquest llibre es un company de _La Tripulacio Agentica: Enginyeria en l'era dels agents d'IA_. Aquell llibre va ser escrit per a enginyers de programari -- persones que escriuen codi per guanyar-se la vida. Aquest es per a tots els altres que se'n surten be amb els ordinadors.

Potser ets un gestor de projectes, un dissenyador, un administrador de sistemes, un analista de dades, un petit empresari, o simplement la persona de la teva familia que arregla el Wi-Fi. Vius entre fulls de calcul, gestiones bústies de correu com un general i ara mateix tens quaranta-set pestanyes del navegador obertes. Pero no has escrit mai una linia de codi -- i no cal que ho facis.

Els agents d'IA estan canviant com es construeix el programari. Aixo t'afecta, tant si treballes al costat de desenvolupadors, com si gestiones un negoci que depen del programari, o simplement intentes entendre que passa al mon que t'envolta. Les idees d'aquest llibre son reals. Hem simplificat els detalls tecnics, pero no els hem aigualit.

Quan acabis, entendras que son realment els agents, com funciona el programari modern per dins i -- el mes important -- com dirigir un agent perque construeixi alguna cosa real. No cal saber programar.

// ─── Chapters ───

#include "chapters/crew-ca/01-welcome-to-the-crew.typ"
#include "chapters/crew-ca/02-the-ground-is-shifting.typ"
#include "chapters/crew-ca/03-whats-under-the-hood.typ"
#include "chapters/crew-ca/04-what-is-an-agent.typ"
#include "chapters/crew-ca/05-how-to-give-good-instructions.typ"
#include "chapters/crew-ca/06-what-the-agent-can-see.typ"
#include "chapters/crew-ca/07-the-trust-gradient.typ"
#include "chapters/crew-ca/08-extending-the-crews-reach.typ"
#include "chapters/crew-ca/09-the-padlock.typ"
#include "chapters/crew-ca/10-reading-the-output-like-a-pro.typ"
#include "chapters/crew-ca/11-building-something-real.typ"
#include "chapters/crew-ca/12-when-things-go-wrong.typ"
#include "chapters/crew-ca/13-when-to-do-it-yourself.typ"
#include "chapters/crew-ca/14-being-the-human-in-the-loop.typ"
#include "chapters/crew-ca/15-talking-to-your-tech-team.typ"
#include "chapters/crew-ca/16-keeping-your-finger-on-the-pulse.typ"
#include "chapters/crew-ca/17-final-words.typ"

// ─── Dedication ───

== \

#align(center)[
  _A tots els qui els van dir_ \
  _"no ets prou tecnic."_ \
  _Ho ets. Sempre ho has estat._ \
  _Ara les eines hi estan d'acord._
]
