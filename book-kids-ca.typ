// La Tripulació Agèntica — Guia per a Nens
// Punt d'entrada principal — compila tots els capítols en un sol PDF

// Segell de revisió — s'auto-incrementa en desplegament
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "La Tripulació Agèntica: Guia per a Nens",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulació Agèntica: Guia per a Nens]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "ca",
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

// ─── Portada ───

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
      #text(size: 8pt, fill: gold, weight: "bold", tracking: 3pt)[PER A JOVES CAPITANS]
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
        )[La Tripulació Agèntica]
      ]
    ]

    // Subtitle
    #place(dx: 8%, dy: 20%)[
      #text(
        size: 12pt,
        fill: gold-light,
        style: "italic",
      )[Guia per a Nens]
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
      #text(size: 7.5pt, fill: gold-dim)[Març 2026]
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── Per als Adults ───

#heading(outlined: false, numbering: none)[Una Nota per als Adults]

Aquest llibre és un company de _La Tripulació Agèntica: Enginyeria a l'era dels agents d'IA_. Aquell llibre va ser escrit per a enginyers de programari. Aquest està escrit per als seus fills — i per a qualsevol nen curiós de nou anys que vulgui entendre de què va tot aquest rebombori.

Les idees són reals. Les hem simplificat, però no les hem aigualit. El teu fill aprendrà què és realment un agent d'IA, per què necessita regles, com comprovar la seva feina i quan és millor fer les coses un mateix. Són les mateixes lliçons que els seus pares estan aprenent a la feina — només que explicades a través de vaixells, robots i algun que altre entrepà explosiu.

Si el teu fill acaba aquest llibre i diu: "Vull provar de donar instruccions a un ordinador" — missió complerta.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _Març 2026_
]

#pagebreak()

// ─── Taula de Continguts ───

#outline(title: "Contingut", indent: 1.5em, depth: 1)

// ─── Capítols ───

#include "chapters/kids-ca/00-prologue.typ"
#include "chapters/kids-ca/01-welcome-aboard.typ"
#include "chapters/kids-ca/02-meet-the-crew.typ"
#include "chapters/kids-ca/03-the-ships-rules.typ"
#include "chapters/kids-ca/04-the-captains-checklist.typ"
#include "chapters/kids-ca/05-how-to-give-good-orders.typ"
#include "chapters/kids-ca/06-when-things-go-wrong.typ"
#include "chapters/kids-ca/07-knowing-when-to-do-it-yourself.typ"
#include "chapters/kids-ca/08-captain-of-a-fleet.typ"
#include "chapters/kids-ca/09-epilogue.typ"

// ─── Dedicatòria ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    Als meus fills — \
    sou la millor tripulació que he tingut mai. \
    Tot això va ser per a vosaltres. \
    Sempre.
  ]
]
