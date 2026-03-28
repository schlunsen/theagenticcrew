// La Tripulación Agéntica — Guía Práctica (Español)
// DEPRECADO — reemplazado por ediciones específicas por sistema operativo:
//   book-hands-on-es-windows.typ
//   book-hands-on-es-mac.typ
//   book-hands-on-es-linux.typ
// Este archivo se conserva como referencia. Usa las versiones por SO.

// Sello de revisión — se auto-incrementa en despliegue
#let revision = sys.inputs.at("revision", default: "dev")


#set document(
  title: "La Tripulación Agéntica: Guía Práctica",
  author: "Rasmus Bornhøft Schlünsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.8in, bottom: 0.8in, left: 0.75in, right: 0.75in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulación Agéntica: Guía Práctica]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 11pt,
  lang: "es",
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

// ─── Portada ───

#page(margin: 0pt, header: none)[
  #let white  = rgb("#f5f0e8")
  #let cream  = rgb("#e8dfc8")
  #let red    = rgb("#d42b2b")

  #block(width: 100%, height: 100%, fill: black)[

    // ── Fondo Bauhaus a sangre completa ──
    #place(dx: 0%, dy: 0%)[
      #image(
        "assets/illustrations/hands-on-cover-fullbleed.jpg",
        width: 100%,
        height: 100%,
        fit: "cover",
      )
    ]

    // ── Eyebrow ──
    #place(dx: 8%, dy: 4%)[
      #text(size: 7pt, fill: cream, weight: "bold", tracking: 4pt)[APRENDE HACIENDO]
    ]

    // ── Título ──
    #place(dx: 8%, dy: 9%)[
      #block(width: 84%)[
        #text(
          size: 34pt,
          weight: "bold",
          fill: white,
          font: "New Computer Modern",
          tracking: -0.6pt,
        )[La Tripulación Agéntica]
      ]
    ]

    // ── Subtítulo ──
    #place(dx: 8%, dy: 76%)[
      #text(size: 11pt, fill: cream, style: "italic")[Guía Práctica]
    ]

    // ── Línea de acento roja ──
    #place(dx: 8%, dy: 83%)[
      #line(length: 84%, stroke: 1.5pt + red)
    ]

    // ── Autor ──
    #place(dx: 8%, dy: 87%)[
      #text(size: 10.5pt, fill: white)[Rasmus Bornhøft Schlünsen]
    ]

    // ── Fecha y revisión ──
    #place(dx: 8%, dy: 94%)[
      #text(size: 7pt, fill: cream.transparentize(30%))[Marzo 2026]
    ]
    #place(dx: 0%, dy: 94%)[
      #h(1fr)
      #text(size: 6pt, fill: cream.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── Una Nota Antes de Empezar ───

#heading(outlined: false, numbering: none)[Una Nota Antes de Empezar]

Este libro es el compañero práctico de _La Tripulación Agéntica_. Mientras el libro principal explica las ideas, este las pone en práctica.

Cada capítulo es un ejercicio. Configurarás herramientas reales, trabajarás con repositorios reales y construirás cosas reales, empezando desde cero. Los ejercicios están diseñados para Windows, pero los conceptos funcionan en cualquier plataforma.

No necesitas ser programador. Sí necesitas estar dispuesto a escribir comandos en una terminal y ver qué pasa. Así es como se aprende esto, no leyendo sobre ello, sino haciéndolo.

Al final de este libro, tendrás un entorno de desarrollo funcional, experiencia práctica con Git y GitHub, y la confianza para colaborar en proyectos reales usando agentes de IA como copiloto.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Marzo 2026_
]

#pagebreak()

// ─── Tabla de Contenidos ───

#outline(title: "Ejercicios", indent: 1.5em, depth: 1)

// ─── Capítulos ───

#include "chapters/hands-on/01-setting-up-your-workstation-es.typ"
#include "chapters/hands-on/02-your-first-pull-request-es.typ"
#include "chapters/hands-on/03-your-first-ai-project-es.typ"

// Capítulos futuros:
// #include "chapters/hands-on/04-pair-programming-with-an-agent-es.typ"
// #include "chapters/hands-on/05-prompts-that-work-es.typ"
// #include "chapters/hands-on/06-building-from-scratch-es.typ"
// #include "chapters/hands-on/07-adding-guardrails-es.typ"
// #include "chapters/hands-on/08-multi-agent-workflows-es.typ"
// #include "chapters/hands-on/09-cicd-with-agents-es.typ"
// #include "chapters/hands-on/10-capstone-project-es.typ"

// ─── Dedicatoria ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    La mejor manera de aprender \
    es publicar algo real. \
    Este libro es tu primer commit.
  ]
]
