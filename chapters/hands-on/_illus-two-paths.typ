// Illustration: Two Paths — Commands vs Prompts
// Side-by-side showing both approaches converging on the same pull request.
// Diffuse oval vignette in cool grey.

#align(center)[
  #v(1.5em)
  #block(width: 280pt, height: 160pt)[

    // ── Diffuse oval vignette (cool grey) ──
    #place(center + horizon)[
      #ellipse(
        width: 278pt,
        height: 155pt,
        fill: gradient.radial(rgb("#eaf0f8"), white),
      )
    ]

    // ── Two-column layout ──
    #place(center + horizon)[
      #block(width: 250pt)[
        #grid(
          columns: (1fr, 12pt, 1fr),
          align: top,

          // ── Left: Commands ──
          block(
            fill: rgb("#0d1117"),
            radius: 4pt,
            inset: (x: 8pt, y: 8pt),
            stroke: 0.5pt + rgb("#30363d"),
            width: 100%,
          )[
            #set align(left)
            #text(size: 5.5pt, fill: rgb("#6e7681"), weight: "bold", tracking: 0.5pt)[COMMANDS]
            #v(5pt)
            #set text(
              size: 6.5pt,
              fill: rgb("#c9d1d9"),
              font: ("Courier New", "Menlo", "DejaVu Sans Mono"),
            )
            #set par(leading: 0.58em)
            #text(fill: rgb("#57ab5a"))[git ] checkout -b review/... \
            #text(fill: rgb("#57ab5a"))[git ] add reviews/ \
            #text(fill: rgb("#57ab5a"))[git ] commit -m "..." \
            #text(fill: rgb("#57ab5a"))[git ] push origin ... \
            #text(fill: rgb("#57ab5a"))[gh ] pr create ...
          ],

          // ── Centre gap ──
          align(center + horizon)[
            #text(size: 9pt, fill: rgb("#94a3b8"))[·]
          ],

          // ── Right: Prompts ──
          block(
            fill: rgb("#f8fafc"),
            radius: 4pt,
            inset: (x: 8pt, y: 8pt),
            stroke: 0.5pt + rgb("#e2e8f0"),
            width: 100%,
          )[
            #set align(left)
            #text(size: 5.5pt, fill: rgb("#64748b"), weight: "bold", tracking: 0.5pt)[PROMPT]
            #v(5pt)
            // Chat bubble
            #block(
              fill: rgb("#eff6ff"),
              radius: (top-right: 8pt, bottom-left: 8pt, bottom-right: 8pt),
              inset: (x: 7pt, y: 6pt),
              stroke: 0.5pt + rgb("#bfdbfe"),
              width: 100%,
            )[
              #set text(size: 6.5pt, fill: rgb("#1e40af"))
              #set par(leading: 0.55em)
              _"Branch, write my review,#linebreak()commit, push, and open a PR."_
            ]
            #v(4pt)
            // Small agent reply
            #align(right)[
              #block(
                fill: rgb("#f0fdf4"),
                radius: (top-left: 8pt, bottom-left: 8pt, top-right: 8pt),
                inset: (x: 6pt, y: 4pt),
                stroke: 0.5pt + rgb("#bbf7d0"),
              )[
                #text(size: 6pt, fill: rgb("#166534"))[Done — PR #47 is open ✓]
              ]
            ]
          ],
        )

        // ── Shared outcome ──
        #v(6pt)
        #align(center)[
          #box(
            fill: white,
            stroke: 1pt + rgb("#3fb950"),
            radius: 3pt,
            inset: (x: 10pt, y: 4pt),
          )[
            #text(size: 6.5pt, fill: rgb("#3fb950"), weight: "bold")[✓ Pull Request opened on GitHub]
          ]
        ]

      ]
    ]

  ]
  #text(size: 7.5pt, fill: luma(140), style: "italic")[Two paths, one destination — commands or prompts, the result is the same]
  #v(1.5em)
]
