// Illustration: AI Studio — agent, HF API, generated assets
// Shows a terminal sending requests to three output panels (image, audio, animation)

#align(center)[
  #v(1.5em)
  #block(width: 320pt, height: 180pt)[

    // ── Background glow ──
    #place(center + horizon)[
      #ellipse(
        width: 318pt,
        height: 178pt,
        fill: gradient.radial(rgb("#1a0a2e"), rgb("#0a0a0a")),
      )
    ]

    // ── Central terminal ──
    #place(center + horizon, dx: -75pt)[
      #block(
        width: 130pt,
        fill: rgb("#0d1117"),
        radius: 5pt,
        stroke: 0.5pt + rgb("#7c3aed"),
        clip: true,
      )[
        // Title bar
        #block(
          width: 100%,
          fill: rgb("#161b22"),
          inset: (x: 8pt, y: 4pt),
        )[
          #set align(left)
          #stack(
            dir: ltr,
            spacing: 3pt,
            box(width: 6pt, height: 6pt, radius: 50%, fill: rgb("#ff5f57")),
            box(width: 6pt, height: 6pt, radius: 50%, fill: rgb("#febc2e")),
            box(width: 6pt, height: 6pt, radius: 50%, fill: rgb("#28c840")),
          )
        ]
        // Prompt lines
        #block(inset: (x: 8pt, y: 6pt))[
          #set text(size: 6pt, fill: rgb("#c9d1d9"), font: ("Courier New", "Menlo", "DejaVu Sans Mono"))
          #set align(left)
          #set par(leading: 0.6em)
          #text(fill: rgb("#c9a84c"))[✦] #h(2pt)claude \
          #v(0.3em)
          #text(fill: rgb("#8b949e"))[> Generate 10 slides] \
          #text(fill: rgb("#8b949e"))[> about climate change] \
          #v(0.3em)
          #text(fill: rgb("#3fb950"))[Calling HF API...] \
          #text(fill: rgb("#3fb950"))[✓ slide-01.jpg] \
          #text(fill: rgb("#3fb950"))[✓ slide-01.mp3]
        ]
      ]
    ]

    // ── Arrow right ──
    #place(center + horizon, dx: 0pt)[
      #text(size: 14pt, fill: rgb("#7c3aed"))[→]
    ]

    // ── Output column ──

    // Image panel
    #place(center + horizon, dx: 55pt, dy: -48pt)[
      #block(
        width: 90pt,
        fill: rgb("#0d1117"),
        radius: 4pt,
        stroke: 0.5pt + rgb("#30363d"),
        inset: (x: 7pt, y: 6pt),
      )[
        #set text(size: 6pt)
        #set align(left)
        #text(fill: rgb("#e879f9"), weight: "bold")[🖼  Illustration] \
        #v(0.2em)
        #block(
          width: 76pt,
          height: 28pt,
          radius: 3pt,
          fill: gradient.linear(
            rgb("#1e1b4b"), rgb("#312e81"),
            angle: 135deg,
          ),
        )[
          #align(center + horizon)[
            #text(size: 5.5pt, fill: rgb("#a5b4fc"))[FLUX.1-schnell]
          ]
        ]
        #v(0.2em)
        #text(fill: rgb("#8b949e"), size: 5.5pt)[slide-01.jpg · 512×512]
      ]
    ]

    // Audio panel
    #place(center + horizon, dx: 55pt, dy: 10pt)[
      #block(
        width: 90pt,
        fill: rgb("#0d1117"),
        radius: 4pt,
        stroke: 0.5pt + rgb("#30363d"),
        inset: (x: 7pt, y: 6pt),
      )[
        #set text(size: 6pt)
        #set align(left)
        #text(fill: rgb("#34d399"), weight: "bold")[🔊  Narration] \
        #v(0.2em)
        // Waveform bars
        #stack(
          dir: ltr,
          spacing: 2pt,
          ..range(16).map(i => {
            let h = (2 + calc.rem(i * 7 + i * i, 14)) * 1pt
            box(width: 3pt, height: h, fill: rgb("#34d399"), radius: 1pt)
          })
        )
        #v(0.2em)
        #text(fill: rgb("#8b949e"), size: 5.5pt)[slide-01.mp3 · mms-tts]
      ]
    ]

    // Animation panel
    #place(center + horizon, dx: 55pt, dy: 68pt)[
      #block(
        width: 90pt,
        fill: rgb("#0d1117"),
        radius: 4pt,
        stroke: 0.5pt + rgb("#30363d"),
        inset: (x: 7pt, y: 6pt),
      )[
        #set text(size: 6pt)
        #set align(left)
        #text(fill: rgb("#fbbf24"), weight: "bold")[✦  Background] \
        #v(0.2em)
        #block(
          width: 76pt,
          height: 18pt,
          radius: 3pt,
          fill: rgb("#0a0a1a"),
          clip: true,
        )[
          // Simulated node network dots
          #place(dx: 10pt, dy: 4pt)[#circle(radius: 1.5pt, fill: rgb("#fbbf24"))]
          #place(dx: 35pt, dy: 2pt)[#circle(radius: 1pt, fill: rgb("#fbbf24"))]
          #place(dx: 58pt, dy: 8pt)[#circle(radius: 1.5pt, fill: rgb("#fbbf24"))]
          #place(dx: 20pt, dy: 11pt)[#circle(radius: 1pt, fill: rgb("#fbbf24"))]
          #place(dx: 48pt, dy: 13pt)[#circle(radius: 1.5pt, fill: rgb("#fbbf24"))]
          // Connecting lines
          #place(dx: 10pt, dy: 5pt)[#line(end: (25pt, -3pt), stroke: 0.5pt + rgb("#fbbf2455"))]
          #place(dx: 35pt, dy: 3pt)[#line(end: (23pt, 5pt), stroke: 0.5pt + rgb("#fbbf2455"))]
          #place(dx: 20pt, dy: 12pt)[#line(end: (28pt, 1pt), stroke: 0.5pt + rgb("#fbbf2455"))]
        ]
        #v(0.2em)
        #text(fill: rgb("#8b949e"), size: 5.5pt)[Three.js · amber theme]
      ]
    ]

  ]
  #text(size: 7.5pt, fill: luma(140), style: "italic")[One prompt. Three AI-generated assets. A complete presentation.]
  #v(1.5em)
]
