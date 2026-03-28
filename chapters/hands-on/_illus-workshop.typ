// Illustration: Setting Up Your Workshop
// A terminal window floating in a diffuse oval vignette, surrounded by tool badges.

#align(center)[
  #v(1.5em)
  #block(width: 280pt, height: 172pt)[

    // ── Diffuse oval vignette (soft blue glow) ──
    #place(center + horizon)[
      #ellipse(
        width: 278pt,
        height: 168pt,
        fill: gradient.radial(rgb("#cde4ff"), white),
      )
    ]

    // ── Terminal window ──
    #place(center + horizon)[
      #block(
        width: 190pt,
        fill: rgb("#0d1117"),
        radius: 5pt,
        stroke: 0.5pt + rgb("#30363d"),
        clip: true,
      )[
        // Title bar
        #block(
          width: 100%,
          fill: rgb("#161b22"),
          inset: (x: 8pt, y: 5pt),
        )[
          #set align(left)
          #stack(
            dir: ltr,
            spacing: 3pt,
            box(width: 7pt, height: 7pt, radius: 50%, fill: rgb("#ff5f57")),
            box(width: 7pt, height: 7pt, radius: 50%, fill: rgb("#febc2e")),
            box(width: 7pt, height: 7pt, radius: 50%, fill: rgb("#28c840")),
          )
        ]
        // Terminal lines
        #block(inset: (x: 10pt, y: 8pt))[
          #set text(size: 7pt, fill: rgb("#c9d1d9"), font: ("Courier New", "Menlo", "DejaVu Sans Mono"))
          #set align(left)
          #set par(leading: 0.55em)
          #text(fill: rgb("#57ab5a"))[PS›] #h(2pt)winget install Git.Git \
          #text(fill: rgb("#555f6e"))[   Successfully installed.] \
          #text(fill: rgb("#57ab5a"))[PS›] #h(2pt)gh auth login \
          #text(fill: rgb("#3fb950"))[   ✓ Logged in to github.com] \
          #text(fill: rgb("#57ab5a"))[PS›] #h(2pt)claude \
          #text(fill: rgb("#c9a84c"))[   ✦ Claude Code ready]
        ]
      ]
    ]

    // ── Tool badges floating around the terminal ──

    // Top-left: Git
    #place(center + horizon, dx: -112pt, dy: -52pt)[
      #box(fill: rgb("#f05033"), radius: 3pt, inset: (x: 6pt, y: 3pt))[
        #text(size: 6.5pt, fill: white, weight: "bold")[Git]
      ]
    ]
    // Top-center: node
    #place(center + horizon, dx: 0pt, dy: -62pt)[
      #box(fill: rgb("#68a063"), radius: 3pt, inset: (x: 6pt, y: 3pt))[
        #text(size: 6.5pt, fill: white, weight: "bold")[node]
      ]
    ]
    // Top-right: gh
    #place(center + horizon, dx: 112pt, dy: -52pt)[
      #box(
        fill: rgb("#161b22"),
        radius: 3pt,
        stroke: 0.5pt + rgb("#c9a84c"),
        inset: (x: 6pt, y: 3pt),
      )[
        #text(size: 6.5pt, fill: rgb("#c9a84c"), weight: "bold")[gh]
      ]
    ]
    // Bottom-left: gemini
    #place(center + horizon, dx: -112pt, dy: 52pt)[
      #box(fill: rgb("#4285f4"), radius: 3pt, inset: (x: 6pt, y: 3pt))[
        #text(size: 6.5pt, fill: white, weight: "bold")[gemini]
      ]
    ]
    // Bottom-right: claude
    #place(center + horizon, dx: 112pt, dy: 52pt)[
      #box(fill: rgb("#c9a84c"), radius: 3pt, inset: (x: 6pt, y: 3pt))[
        #text(size: 6.5pt, fill: rgb("#0a0e1a"), weight: "bold")[claude]
      ]
    ]

  ]
  #text(size: 7.5pt, fill: luma(140), style: "italic")[Your terminal: the workshop where everything begins]
  #v(1.5em)
]
