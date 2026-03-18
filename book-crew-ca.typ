// La Tripulacio Agentica — Guia del Tripulant
// Per a persones amb coneixements tecnics que no escriuen codi
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "La Tripulacio Agentica: Guia del Tripulant",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulacio Agentica: Guia del Tripulant]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "ca",
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
  #let sea-green = rgb("#2d8a6e")

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 4pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 8%)[
      #text(size: 8pt, fill: gold, weight: "bold", tracking: 3pt)[PER A TOTA LA TRIPULACIO]
    ]

    // Title
    #place(dx: 8%, dy: 14%)[
      #block(width: 84%)[
        #text(
          size: 30pt,
          weight: "bold",
          fill: cream,
          font: "New Computer Modern",
          tracking: -0.4pt,
        )[La Tripulacio Agentica]
      ]
    ]

    // Subtitle
    #place(dx: 8%, dy: 24%)[
      #text(
        size: 12pt,
        fill: gold-light,
        style: "italic",
      )[Guia del Tripulant]
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
      #text(size: 7.5pt, fill: gold-dim)[Marc 2026]
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

#heading(outlined: false, numbering: none)[Una nota abans de comecar]

Aquest llibre es un company de _La Tripulacio Agentica: Enginyeria en l'era dels agents d'IA_. Aquell llibre va ser escrit per a enginyers de programari -- persones que escriuen codi per guanyar-se la vida. Aquest es per a tots els altres que se'n surten be amb els ordinadors.

Potser ets un gestor de projectes, un dissenyador, un administrador de sistemes, un analista de dades, un petit empresari, o simplement la persona de la teva familia que arregla el Wi-Fi. Vius entre fulls de calcul, gestiones bústies de correu com un general i ara mateix tens quaranta-set pestanyes del navegador obertes. Pero no has escrit mai una linia de codi -- i no cal que ho facis.

Els agents d'IA estan canviant com es construeix el programari. Aixo t'afecta, tant si treballes al costat de desenvolupadors, com si gestiones un negoci que depen del programari, o simplement intentes entendre que passa al mon que t'envolta. Les idees d'aquest llibre son reals. Hem simplificat els detalls tecnics, pero no els hem aigualit.

Quan acabis, entendras que son realment els agents, com funciona el programari modern per dins i -- el mes important -- com dirigir un agent perque construeixi alguna cosa real. No cal saber programar.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _Marc 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Que hi ha dins", indent: 1.5em, depth: 1)

// ─── Chapters ───

#include "chapters/crew-ca/01-welcome-to-the-crew.typ"
#include "chapters/crew-ca/02-the-ground-is-shifting.typ"
#include "chapters/crew-ca/03-whats-under-the-hood.typ"
#include "chapters/crew-ca/04-what-is-an-agent.typ"
#include "chapters/crew-ca/05-how-to-give-good-instructions.typ"
#include "chapters/crew-ca/06-what-the-agent-can-see.typ"
#include "chapters/crew-ca/07-the-trust-gradient.typ"
#include "chapters/crew-ca/08-extending-the-crews-reach.typ"
#include "chapters/crew-ca/09-reading-the-output-like-a-pro.typ"
#include "chapters/crew-ca/10-building-something-real.typ"
#include "chapters/crew-ca/11-when-things-go-wrong.typ"
#include "chapters/crew-ca/12-when-to-do-it-yourself.typ"
#include "chapters/crew-ca/13-being-the-human-in-the-loop.typ"
#include "chapters/crew-ca/14-talking-to-your-tech-team.typ"
#include "chapters/crew-ca/15-keeping-your-finger-on-the-pulse.typ"
#include "chapters/crew-ca/16-final-words.typ"

// ─── Dedication ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    A tots els qui els van dir \
    "no ets prou tecnic." \
    Ho ets. Sempre ho has estat. \
    Ara les eines hi estan d'acord.
  ]
]
