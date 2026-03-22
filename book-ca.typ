// La Tripulacio Agentica
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "La Tripulacio Agentica",
  author: "Rasmus Bornhoft Schlunsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.75in, bottom: 0.75in, left: 0.7in, right: 0.7in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[La Tripulacio Agentica]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 10pt,
  lang: "ca",
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

// ─── Cover Page ───

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
      #text(size: 7.5pt, fill: gold, weight: "bold", tracking: 3pt)[UNA GUIA DE CAMP]
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
        )[La Tripulacio Agentica]
      ]
    ]

    // Subtitle — below the wheel
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          size: 11pt,
          fill: gold-light.transparentize(20%),
          style: "italic",
        )[Enginyeria en l'era dels agents d'IA]
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
      )[Rasmus Bornhoft Schlunsen]
    ]

    // Date & revision
    #place(dx: 8%, dy: 93%)[
      #text(size: 7.5pt, fill: gold-dim)[Marc 2026]
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

// ─── Foreword ───

#heading(outlined: false, numbering: none)[Proleg]

Era un dimarts al vespre, en algun moment de l'any passat. Els meus fills dormien, i jo estava mirant un script de migracio que havia estat ajornant tota la setmana -- el tipus de reordenament tediosa, taula per taula, que et menja un dia sencer si vas amb compte, i destrossa produccio si no. Per capritx, vaig descriure el problema a un agent. L'esquema aqui, les restriccions alla, vigila amb aquesta clau forana. Llavors vaig premer enter i vaig anar a fer-me un te.

Quan vaig tornar, l'script estava fet. No un esborrany. _Fet._ Casos limits correctes, logica de rollback, comentaris que jo mateix hauria escrit. Vaig quedar-me assegut una bona estona, el te refredant-se, sentint dues coses alhora: una admiracio genuina -- i un temor silencis i creixent.

Perque aquella migracio? Aixo era _la meva_ especialitat. Jo era la persona de l'equip que podia tenir tot l'esquema al cap, que sabia quins joins estaven maleits, que podia escriure l'SQL acurat a ma. Quinze anys de memoria muscular, i un LLM ho havia igualat en quatre minuts mentre jo bullia aigua.

Vull ser honest amb tu: aquella nit no vaig dormir be. Vaig estar al llit donant voltes al mateix bucle que tots els enginyers que conec han donat. _Per a que serveixo ara? Que passa amb l'ofici que he passat mitja vida construint? Estic entrenant el meu substitut?_

Em va costar mesos -- i molt de construir, fracassar i reconstruir amb aquestes eines -- trobar la resposta. I la resposta em va sorprendre. L'ofici no s'esta morint. Esta _mudant_. La capa exterior -- les pulsacions de tecles, la sintaxi, el codi repetitiu -- aquesta part esta caient. Pero l'animal de sota? La part que sap _que_ construir i _per que_, que endevina una mala abstraccio a tres fitxers de distancia, que pot tenir tot un sistema al cap i sentir on es fragil? Aquesta part esta mes viva que mai.

No ens estan substituint. Ens estan ascendint. De mecanografs a pensadors. D'escriure codi a dirigir-lo -- orquestrar, revisar, donar forma. Les habilitats que et feien bon enginyer -- pensament sistemic, gust, judici, l'instint per la simplicitat -- ara son _tot el joc_, no nomes el soroll de fons.

Pero ningu ens va donar un manual per a aquesta transicio. Es desordenada i incomoda i de vegades humiliant. Vaig escriure aquest llibre perque l'estic vivint, i tinc la sensacio que tu tambe. Aquestes pagines son tot el que he apres sobre treballar _amb_ els agents en lloc de contra ells -- o pitjor, fingir que no existeixen.

Si alguna vegada has vist una IA escriure codi que semblava teu i has sentit un nus a l'estomac, aquest llibre es per a tu. Continua llegint. Es millor -- i mes estrany -- del que penses.

#align(right)[
  _Rasmus Bornhoft Schlunsen_ \
  _Marc 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Continguts", indent: 1.5em, depth: 2)

// ─── Chapters ───

#include "chapters/ca/01-introduction.typ"
#include "chapters/ca/02-context.typ"
#include "chapters/ca/03-what-is-an-agent.typ"
#include "chapters/ca/04-guardrails.typ"
#include "chapters/ca/05-git.typ"
#include "chapters/ca/06-sandboxes.typ"
#include "chapters/ca/07-testing-as-the-feedback-loop.typ"
#include "chapters/ca/08-convention-over-configuration.typ"
#include "chapters/ca/09-tool-integrations.typ"
#include "chapters/ca/10-local-vs-commercial-llms.typ"
#include "chapters/ca/11-prompting-as-engineering.typ"
#include "chapters/ca/12-multi-agent-orchestration.typ"
#include "chapters/ca/13-cicd-and-agents.typ"
#include "chapters/ca/14-war-stories.typ"
#include "chapters/ca/18-agents-as-pentesters.typ"
#include "chapters/ca/15-when-not-to-use-agents.typ"
#include "chapters/ca/16-agentic-teams.typ"
#include "chapters/ca/17-final-words.typ"

// ─── Dedication (End) ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    Als meus fills -- \
    sou la millor tripulacio que he tingut mai. \
    Tot aixo era per a vosaltres. \
    Sempre.
  ]
]
