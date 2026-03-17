// Det Agentiske Mandskab
// Main entry point — compiles all chapters into a single PDF

// Revision stamp — auto-incremented on deploy
#let revision = sys.inputs.at("revision", default: "dev")

#set document(
  title: "Det Agentiske Mandskab",
  author: "Rasmus Bornhøft Schlünsen",
)

#set page(
  paper: "a5",
  margin: (top: 0.75in, bottom: 0.75in, left: 0.7in, right: 0.7in),
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 9pt, fill: luma(100))
      emph[Det Agentiske Mandskab]
      h(1fr)
      counter(page).display()
    }
  },
)

#set text(
  font: "New Computer Modern",
  size: 10pt,
  lang: "da",
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
      #text(size: 7.5pt, fill: gold, weight: "bold", tracking: 3pt)[EN FELTHÅNDBOG]
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
        )[Det Agentiske Mandskab]
      ]
    ]

    // Subtitle — below the wheel
    #place(dx: 8%, dy: 72%)[
      #block(width: 84%)[
        #text(
          size: 11pt,
          fill: gold-light.transparentize(20%),
          style: "italic",
        )[Softwareudvikling i en tid med AI-agenter]
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
      #text(size: 7.5pt, fill: gold-dim)[Marts 2026]
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

#heading(outlined: false, numbering: none)[Forord]

Det var en tirsdag aften, engang sidste år. Mine børn sov, og jeg sad og stirrede på et migrationsscript, som jeg havde udskudt hele ugen — den slags kedelige, tabel-for-tabel omrokeringer, der æder en hel dag, hvis man er omhyggelig, og smadrer produktion, hvis man ikke er. På et indfald beskrev jeg problemet for en agent. Skemaet her, begrænsningerne der, pas på den fremmednøgle. Så trykkede jeg enter og gik ud for at lave te.

Da jeg kom tilbage, var scriptet færdigt. Ikke et udkast. _Færdigt._ Korrekte edge cases, rollback-logik, kommentarer jeg selv ville have skrevet. Jeg sad der længe, teen blev kold, og jeg følte to ting på én gang: ægte ærefrygt — og en stille, krybende angst.

For den migration? Det var _min_ ting. Jeg var personen på holdet, der kunne holde hele skemaet i hovedet, som vidste hvilke joins der var forbandede, som kunne skrive den omhyggelige SQL i hånden. Femten års muskelhukommelse, og en LLM havde lige matchet det på fire minutter, mens jeg kogte vand.

Jeg vil være ærlig med dig: jeg sov ikke godt den nat. Jeg lå i sengen og kørte den samme løkke, som alle ingeniører jeg kender har kørt. _Hvad skal jeg så bruges til nu? Hvad sker der med det håndværk, jeg har brugt halvdelen af mit liv på at bygge op? Er jeg ved at træne min egen afløser?_

Det tog mig måneder — og en masse byggeri, fejlslag og genopbygning med de her værktøjer — at finde svaret. Og svaret overraskede mig. Håndværket er ikke ved at dø. Det _skifter ham._ Den ydre skal — tastetrykkene, syntaksen, boilerplaten — den del falder af. Men dyret indenunder? Den del, der ved _hvad_ man skal bygge og _hvorfor_, der kan lugte en dårlig abstraktion tre filer væk, der kan holde et helt system i hovedet og mærke, hvor det er skrøbeligt? Den del er mere levende end nogensinde.

Vi bliver ikke erstattet. Vi bliver forfremmet. Fra maskinskrivere til tænkere. Fra at skrive kode til at dirigere den — orkestrere, reviewe, forme. De evner, der gjorde dig til en god ingeniør — systemtænkning, smag, dømmekraft, instinktet for enkelhed — det er _hele spillet_ nu, ikke bare baggrundsstøjen.

Men ingen gav os en manual til den her overgang. Den er rodet og ubehagelig og til tider ydmygende. Jeg skrev denne bog, fordi jeg lever midt i det, og jeg har en fornemmelse af, at du også gør. Disse sider er alt, hvad jeg har lært om at arbejde _med_ agenterne i stedet for imod dem — eller endnu værre, lade som om de ikke eksisterer.

Hvis du nogensinde har set en AI skrive kode, der lignede din egen, og mærket maven synke, så er denne bog til dig. Bliv ved med at læse. Det bliver bedre — og mærkeligere — end du tror.

#align(right)[
  _Rasmus Bornhøft Schlünsen_ \
  _Marts 2026_
]

#pagebreak()

// ─── Table of Contents ───

#outline(title: "Indhold", indent: 1.5em, depth: 2)

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
#include "chapters/da/12b-cicd-and-agents.typ"
#include "chapters/da/13-war-stories.typ"
#include "chapters/da/14-when-not-to-use-agents.typ"
#include "chapters/da/15-agentic-teams.typ"
#include "chapters/da/16-final-words.typ"

// ─── Dedication (End) ───

#pagebreak()

#align(center + horizon)[
  #text(size: 14pt, style: "italic")[
    Til mine børn — \
    I er det bedste mandskab, jeg nogensinde har haft. \
    Det hele var for jer. \
    Altid.
  ]
]
