// Illustration: The Pull Request Flow
// upstream → fork → branch → PR, inside a warm gold-tinted diffuse oval vignette.

#align(center)[
  #v(1.5em)
  #block(width: 280pt, height: 155pt)[

    // ── Diffuse oval vignette (warm gold tint) ──
    #place(center + horizon)[
      #ellipse(
        width: 278pt,
        height: 150pt,
        fill: gradient.radial(rgb("#f5e9c4"), white),
      )
    ]

    // ── Flow diagram ──
    #place(center + horizon)[
      #block(width: 256pt)[

        // Three repo boxes connected by arrows
        #grid(
          columns: (1fr, 20pt, 1fr, 20pt, 1fr),
          align: center + horizon,

          // ── Box 1: Upstream ──
          block(
            fill: rgb("#1e293b"),
            radius: 4pt,
            inset: (x: 6pt, y: 9pt),
            stroke: 0.5pt + rgb("#475569"),
            width: 100%,
          )[
            #set align(center)
            #text(size: 5.5pt, fill: rgb("#94a3b8"), weight: "bold", tracking: 0.5pt)[UPSTREAM]
            #v(3pt)
            #text(size: 6pt, fill: rgb("#64748b"))[schlunsen/] \
            #text(size: 6pt, fill: rgb("#64748b"))[theagenticcrew]
          ],

          // ── Arrow 1: fork ──
          align(center)[
            #set text(fill: rgb("#6b7280"))
            #text(size: 8pt)[→]
            #v(1pt)
            #text(size: 4.5pt, style: "italic")[fork]
          ],

          // ── Box 2: Your Fork ──
          block(
            fill: rgb("#0a0e1a"),
            radius: 4pt,
            inset: (x: 6pt, y: 9pt),
            stroke: 1pt + rgb("#c9a84c"),
            width: 100%,
          )[
            #set align(center)
            #text(size: 5.5pt, fill: rgb("#c9a84c"), weight: "bold", tracking: 0.5pt)[YOUR FORK]
            #v(3pt)
            #text(size: 6pt, fill: rgb("#6b7280"))[you/] \
            #text(size: 6pt, fill: rgb("#6b7280"))[theagenticcrew]
          ],

          // ── Arrow 2: PR ──
          align(center)[
            #set text(fill: rgb("#6b7280"))
            #text(size: 8pt)[→]
            #v(1pt)
            #text(size: 4.5pt, style: "italic")[PR]
          ],

          // ── Box 3: Pull Request ──
          block(
            fill: rgb("#0d1f18"),
            radius: 4pt,
            inset: (x: 6pt, y: 9pt),
            stroke: 1pt + rgb("#3fb950"),
            width: 100%,
          )[
            #set align(center)
            #text(size: 5.5pt, fill: rgb("#3fb950"), weight: "bold", tracking: 0.5pt)[PULL REQUEST]
            #v(3pt)
            #text(size: 6pt, fill: rgb("#6b7280"))[review/chapter-1-] \
            #text(size: 6pt, fill: rgb("#6b7280"))[your-username]
          ],
        )

        // ── Branch legend ──
        #v(10pt)
        #align(center)[
          #stack(
            dir: ltr,
            spacing: 5pt,
            box(width: 22pt, height: 4pt, radius: 2pt, fill: rgb("#475569")),
            text(size: 5.5pt, fill: rgb("#94a3b8"))[main],
            h(6pt),
            box(width: 22pt, height: 4pt, radius: 2pt, fill: rgb("#c9a84c")),
            text(size: 5.5pt, fill: rgb("#a88a3a"))[review/chapter-1-you],
            h(6pt),
            box(width: 22pt, height: 4pt, radius: 2pt, fill: rgb("#3fb950")),
            text(size: 5.5pt, fill: rgb("#3fb950"))[merged ✓],
          )
        ]
      ]
    ]

  ]
  #text(size: 7.5pt, fill: luma(140), style: "italic")[fork → branch → pull request: the open-source contribution loop]
  #v(1.5em)
]
