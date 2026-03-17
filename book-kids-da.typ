// Det Agentiske Mandskab — Børneguide
// Hovedindgang — kompilerer alle kapitler til én PDF

// Revisionsstempel — auto-inkrementeret ved deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "Det Agentiske Mandskab: Børneguide",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[Det Agentiske Mandskab: Børneguide]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "da",
)

#set par(
  justify: true,
  leading: 0.8em,
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

// ─── Forside ───

#page(margin: 0pt, header: none)[
  #let bg = rgb("#0a0e1a")
  #let gold = rgb("#c9a84c")
  #let gold-light = rgb("#e0c878")
  #let gold-dim = rgb("#6b5a2e")
  #let cream = rgb("#f0ead6")
  #let navy = rgb("#1a2040")
  #let sky-blue = rgb("#4a90d9")

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Cover illustration
    #place(dx: 15%, dy: 25%)[
      #image("assets/kids/cover.jpg", width: 70%)
    ]

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 4pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 5%)[
      #text(size: 8pt, fill: gold, weight: "bold", tracking: 3pt)[FOR UNGE KAPTAJNER]
    ]

    // Title
    #place(dx: 8%, dy: 10%)[
      #block(width: 84%)[
        #text(
          size: 30pt,
          weight: "bold",
          fill: cream,
          font: "New Computer Modern",
          tracking: -0.4pt,
        )[Det Agentiske Mandskab]
      ]
    ]

    // Subtitle
    #place(dx: 8%, dy: 20%)[
      #text(
        size: 12pt,
        fill: gold-light,
        style: "italic",
      )[Børneguide]
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
      #text(size: 7.5pt, fill: gold-dim)[Marts 2026]
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── Til de Voksne ───

#heading(outlined: false, numbering: none)[En Besked til de Voksne]

Denne bog er en ledsager til _Det Agentiske Mandskab: Ingeniørkunst i AI-agenternes tidsalder_. Den bog blev skrevet til softwareingeniører. Denne er skrevet til deres børn — og til enhver nysgerrig niårig, der vil forstå, hvad al den ballade handler om.

Ideerne er ægte. Vi har forenklet dem, men vi har ikke udvandet dem. Dit barn vil lære, hvad en AI-agent faktisk er, hvorfor den har brug for regler, hvordan man tjekker dens arbejde, og hvornår det er bedre at gøre tingene selv. Det er de samme lektioner, som deres forældre lærer på arbejdet — bare fortalt gennem skibe, robotter og den lejlighedsvise eksploderende sandwich.

Hvis dit barn afslutter denne bog og siger: "Jeg vil prøve at give en computer instruktioner" — mission fuldført.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _Marts 2026_
]

#pagebreak()

// ─── Indholdsfortegnelse ───

#outline(title: "Indhold", indent: 1.5em, depth: 1)

// ─── Kapitler ───

#include "chapters/kids-da/00-prologue.typ"
#include "chapters/kids-da/01-welcome-aboard.typ"
#include "chapters/kids-da/02-meet-the-crew.typ"
#include "chapters/kids-da/03-the-ships-rules.typ"
#include "chapters/kids-da/04-the-captains-checklist.typ"
#include "chapters/kids-da/05-how-to-give-good-orders.typ"
#include "chapters/kids-da/06-when-things-go-wrong.typ"
#include "chapters/kids-da/07-knowing-when-to-do-it-yourself.typ"
#include "chapters/kids-da/08-captain-of-a-fleet.typ"
#include "chapters/kids-da/09-epilogue.typ"

// ─── Dedikation ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    Til mine børn — \
    I er det bedste mandskab, jeg nogensinde har haft. \
    Alt dette var for jer. \
    Altid.
  ]
]
