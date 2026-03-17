// La Tripulación Agéntica — Guía para Niños
// Punto de entrada principal — compila todos los capítulos en un solo PDF

// Sello de revisión — se auto-incrementa en despliegue
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "La Tripulación Agéntica: Guía para Niños",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulación Agéntica: Guía para Niños]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 12pt,
  lang: "es",
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
      #text(size: 8pt, fill: gold, weight: "bold", tracking: 3pt)[PARA JÓVENES CAPITANES]
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
        )[La Tripulación Agéntica]
      ]
    ]

    // Subtitle
    #place(dx: 8%, dy: 20%)[
      #text(
        size: 12pt,
        fill: gold-light,
        style: "italic",
      )[Guía para Niños]
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
      #text(size: 7.5pt, fill: gold-dim)[Marzo 2026]
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── Para los Adultos ───

#heading(outlined: false, numbering: none)[Una Nota para los Adultos]

Este libro es un complemento de _La Tripulación Agéntica: Ingeniería en la era de los agentes de IA_. Ese libro fue escrito para ingenieros de software. Este está escrito para sus hijos — y para cualquier niño curioso de nueve años que quiera entender de qué va todo este revuelo.

Las ideas son reales. Las hemos simplificado, pero no las hemos aguado. Tu hijo aprenderá qué es realmente un agente de IA, por qué necesita reglas, cómo comprobar su trabajo y cuándo es mejor hacer las cosas uno mismo. Son las mismas lecciones que sus padres están aprendiendo en el trabajo — solo que contadas a través de barcos, robots y algún que otro sándwich explosivo.

Si tu hijo termina este libro y dice: "Quiero intentar darle instrucciones a un ordenador" — misión cumplida.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _Marzo 2026_
]

#pagebreak()

// ─── Tabla de Contenidos ───

#outline(title: "Contenido", indent: 1.5em, depth: 1)

// ─── Capítulos ───

#include "chapters/kids-es/00-prologue.typ"
#include "chapters/kids-es/01-welcome-aboard.typ"
#include "chapters/kids-es/02-meet-the-crew.typ"
#include "chapters/kids-es/03-the-ships-rules.typ"
#include "chapters/kids-es/04-the-captains-checklist.typ"
#include "chapters/kids-es/05-how-to-give-good-orders.typ"
#include "chapters/kids-es/06-when-things-go-wrong.typ"
#include "chapters/kids-es/07-knowing-when-to-do-it-yourself.typ"
#include "chapters/kids-es/08-captain-of-a-fleet.typ"
#include "chapters/kids-es/09-epilogue.typ"

// ─── Dedicatoria ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    A mis hijos — \
    sois la mejor tripulación que he tenido. \
    Todo esto fue para vosotros. \
    Siempre.
  ]
]
