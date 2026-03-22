// La Tripulación Agéntica
// Punto de entrada principal — compila todos los capítulos en un solo PDF

// Sello de revisión — se auto-incrementa en despliegue
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "La Tripulación Agéntica",
  author: "Rasmus Bornhøft Schlünsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.75in, bottom: 0.75in, left: 0.7in, right: 0.7in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulación Agéntica]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 10pt,
  lang: "es",
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

// ─── Portada ───

#page(margin: 0pt, header: none)[
  #let bg = rgb("#0a0e1a")
  #let gold = rgb("#c9a84c")
  #let gold-light = rgb("#e0c878")
  #let gold-dim = rgb("#6b5a2e")
  #let cream = rgb("#f0ead6")
  #let navy = rgb("#1a2040")

  // Ship's wheel (helm) drawn with Typst primitives
  #let helm(cx, cy, outer-r, spoke-count: 8, col: gold) = {
    // Outer ring
    place(dx: cx - outer-r, dy: cy - outer-r)[
      #circle(radius: outer-r, stroke: 2pt + col)
    ]
    // Inner ring
    place(dx: cx - outer-r * 0.55, dy: cy - outer-r * 0.55)[
      #circle(radius: outer-r * 0.55, stroke: 1.2pt + col)
    ]
    // Centre hub
    place(dx: cx - outer-r * 0.12, dy: cy - outer-r * 0.12)[
      #circle(radius: outer-r * 0.12, fill: col)
    ]
    // Spokes
    for i in range(spoke-count) {
      let angle = i * 360deg / spoke-count
      let spoke-len = outer-r * 2
      place(dx: cx, dy: cy)[
        #line(length: spoke-len, angle: angle, stroke: 1.5pt + col)
      ]
    }
    // Handle pegs at end of each spoke (small circles)
    for i in range(spoke-count) {
      let angle = i * 360deg / spoke-count
      let peg-x = cx + outer-r * 1.15 * calc.cos(angle) - 3.5pt
      let peg-y = cy + outer-r * 1.15 * calc.sin(angle) - 3.5pt
      place(dx: peg-x, dy: peg-y)[
        #circle(radius: 3.5pt, fill: col)
      ]
    }
  }

  #block(width: 100%, height: 100%, fill: bg)[

    // Subtle gradient overlay at top
    #place(dx: 0%, dy: 0%)[
      #rect(width: 100%, height: 40%, fill: gradient.linear(navy, bg))
    ]

    // Ship's wheel — centred, large, slightly faded
    #helm(52%, 42%, 55pt, col: gold.transparentize(25%))

    // Left gold accent strip
    #place(dx: 0%, dy: 0%)[
      #rect(width: 3.5pt, height: 100%, fill: gold)
    ]

    // Eyebrow
    #place(dx: 8%, dy: 8%)[
      #text(size: 7.5pt, fill: gold, weight: "bold", tracking: 3pt)[UNA GUÍA DE CAMPO]
    ]

    // Title
    #place(dx: 8%, dy: 14%)[
      #block(width: 84%)[
        #text(
          size: 34pt,
          weight: "bold",
          fill: cream,
          font: "New Computer Modern",
          tracking: -0.6pt,
        )[La Tripulación Agéntica]
      ]
    ]

    // Subtitle — below the wheel
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          size: 11pt,
          fill: gold-light.transparentize(20%),
          style: "italic",
        )[Ingeniería en la era de los agentes de IA]
      ]
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
      )[Rasmus Bornhøft Schlünsen]
    ]

    // Date & revision
    #place(dx: 8%, dy: 93%)[
      #text(size: 7.5pt, fill: gold-dim)[Marzo 2026]
      #h(1fr)
    ]
    #place(dx: 0%, dy: 93%)[
      #h(1fr)
      #text(size: 6pt, fill: gold-dim.transparentize(50%))[rev #revision]
      #h(8%)
    ]
  ]
]

#pagebreak()

// ─── Prólogo ───

#heading(outlined: false, numbering: none)[Prólogo]

Era un martes por la noche, en algún momento del año pasado. Mis hijos estaban dormidos, y yo miraba un script de migración que llevaba temiendo toda la semana — ese tipo de reorganización tediosa, tabla por tabla, que se come un día entero si eres cuidadoso y destroza producción si no lo eres. Por capricho, le describí el problema a un agente. El esquema aquí, las restricciones allá, cuidado con esta clave foránea. Luego pulsé enter y fui a preparar un té.

Cuando volví, el script estaba hecho. No un borrador. _Hecho._ Casos límite correctos, lógica de rollback, comentarios que yo mismo habría escrito. Me quedé sentado un buen rato, el té enfriándose, sintiendo dos cosas a la vez: asombro genuino — y un temor silencioso y creciente.

Porque esa migración era _mi_ cosa. Yo era la persona del equipo que podía mantener todo el esquema en la cabeza, que sabía qué joins estaban malditos, que podía escribir el SQL cuidadoso a mano. Quince años de memoria muscular, y un LLM acababa de igualarlo en cuatro minutos mientras yo hervía agua.

Quiero ser honesto contigo: esa noche no dormí bien. Me quedé en la cama ejecutando el mismo bucle que todo ingeniero que conozco ha ejecutado. _¿Para qué sirvo ahora? ¿Qué pasa con el oficio que pasé media vida construyendo? ¿Estoy entrenando a mi reemplazo?_

Me llevó meses — y mucho construir, fallar y reconstruir con estas herramientas — encontrar la respuesta. Y la respuesta me sorprendió. El oficio no está muriendo. Está _mudando_. La cáscara exterior — las pulsaciones de teclas, la sintaxis, el boilerplate — esa parte se está cayendo. Pero el animal debajo, la parte que sabe _qué_ construir y _por qué_, que huele una mala abstracción a tres archivos de distancia, que puede mantener todo un sistema en la mente y sentir dónde es frágil — esa parte está más viva que nunca.

No estamos siendo reemplazados. Estamos siendo promovidos. De mecanógrafos a pensadores. De escribir código a dirigirlo — orquestar, revisar, dar forma. Las habilidades que te hicieron buen ingeniero — pensamiento de sistemas, gusto, criterio, el instinto por la simplicidad — esas son _todo el juego_ ahora, no solo el ruido de fondo.

Pero nadie nos dio un manual para esta transición. Es desordenada e incómoda y a veces humillante. Escribí este libro porque estoy viviéndola, y tengo la sensación de que tú también. Estas páginas son todo lo que he aprendido sobre trabajar _con_ los agentes en lugar de contra ellos — o peor, fingir que no existen.

Si alguna vez has visto a una IA escribir código que se parecía al tuyo y has sentido un vuelco en el estómago, este libro es para ti. Sigue leyendo. Se pone mejor — y más extraño — de lo que crees.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Marzo 2026_
]

#pagebreak()

// ─── Tabla de Contenidos ───

#outline(title: "Contenidos", indent: 1.5em, depth: 2)

// ─── Capítulos ───

#include "chapters/es/01-introduction.typ"
#include "chapters/es/02-context.typ"
#include "chapters/es/03-what-is-an-agent.typ"
#include "chapters/es/04-guardrails.typ"
#include "chapters/es/05-git.typ"
#include "chapters/es/06-sandboxes.typ"
#include "chapters/es/07-testing-as-the-feedback-loop.typ"
#include "chapters/es/08-convention-over-configuration.typ"
#include "chapters/es/09-tool-integrations.typ"
#include "chapters/es/10-local-vs-commercial-llms.typ"
#include "chapters/es/11-prompting-as-engineering.typ"
#include "chapters/es/12-multi-agent-orchestration.typ"
#include "chapters/es/13-cicd-and-agents.typ"
#include "chapters/es/14-war-stories.typ"
#include "chapters/es/18-agents-as-pentesters.typ"
#include "chapters/es/15-when-not-to-use-agents.typ"
#include "chapters/es/16-agentic-teams.typ"
#include "chapters/es/17-final-words.typ"

// ─── Dedicatoria (Final) ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    A mis hijos — \
    sois la mejor tripulación que he tenido. \
    Todo esto fue para vosotros. \
    Siempre.
  ]
]
