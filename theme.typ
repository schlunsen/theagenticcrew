// The Agentic Crew — interior book theme ("Midnight & Brass")
// Shared by book.typ. Fonts live in assets/fonts (compile with --font-path assets/fonts).

#let navy = rgb("#0a0e1a")
#let navy-2 = rgb("#161d3a")
#let brass = rgb("#a8832f")        // brass tuned for contrast on white
#let brass-light = rgb("#c9a84c")  // brass as on the cover
#let brass-pale = rgb("#e0c878")
#let cream = rgb("#f0ead6")
#let ink = rgb("#1b1e29")
#let muted = rgb("#6d6758")
#let rule = rgb("#d9cfb4")
#let tint = rgb("#f6f1e4")

#let serif = ("Source Serif 4", "Iowan Old Style", "Georgia")
#let display = ("Fraunces", "Iowan Old Style", "Georgia")
#let sans = ("Inter", "Helvetica Neue", "Arial")
#let mono = ("JetBrains Mono", "Menlo")

// Small-caps-style label: tracked uppercase sans.
#let label-text(body, size: 6.8pt, fill: brass, tracking: 1.6pt) = text(
  font: sans, size: size, weight: 500, tracking: tracking, fill: fill, upper(body),
)

// ── Helm ornament (same geometry as the cover) ──
#let helm(r, col: brass-light, stroke-w: 0.6pt) = {
  let s = stroke-w + col
  box(width: 4 * r, height: 4 * r, {
    let c = 2 * r
    place(dx: c - r, dy: c - r, circle(radius: r, stroke: (thickness: stroke-w * 1.6, paint: col)))
    place(dx: c - r * 0.55, dy: c - r * 0.55, circle(radius: r * 0.55, stroke: s))
    for i in range(8) {
      let a = i * 45deg
      place(line(start: (c - 2 * r * calc.cos(a), c - 2 * r * calc.sin(a)), end: (c + 2 * r * calc.cos(a), c + 2 * r * calc.sin(a)), stroke: s))
      place(dx: c + r * 1.15 * calc.cos(a) - r * 0.07, dy: c + r * 1.15 * calc.sin(a) - r * 0.07, circle(radius: r * 0.07, fill: col))
    }
    place(dx: c - r * 0.12, dy: c - r * 0.12, circle(radius: r * 0.12, fill: col))
  })
}

// ── Heading kinds ──
// Parts and appendices are unnumbered level-1 headings marked with a label.
#let is-part(h) = h.has("label") and h.label == <part>
#let is-appendix(h) = h.has("label") and h.label == <appendix>

// A full navy divider page introducing a part of the book.
#let part(numeral, title, subtitle) = page(
  fill: navy, header: none, footer: none,
  margin: (x: 0.8in, top: 1.6in, bottom: 0.9in),
)[
  #set text(fill: cream)
  #place(bottom + right, dx: 0.9in, dy: 0.75in, helm(0.95in, col: brass-light.transparentize(72%), stroke-w: 0.5pt))
  #if numeral != "" { label-text([Part #numeral], size: 7.5pt, fill: brass-light, tracking: 3pt) } else { label-text([The Agentic Crew], size: 7.5pt, fill: brass-light, tracking: 3pt) }
  #v(0.9em)
  #heading(level: 1, numbering: none, supplement: if numeral != "" [Part #numeral] else [])[#title] <part>
  #v(0.8em)
  #line(length: 1.4cm, stroke: 0.7pt + brass-light)
  #v(1em)
  #block(width: 78%, text(font: display, style: "italic", weight: 300, size: 11pt, fill: cream.transparentize(25%), subtitle))
]

#let appendix(letter, title) = [#heading(level: 1, numbering: none, supplement: [Appendix #letter])[#title] <appendix>]

// ── The template ──
#let book(revision: "dev", body) = {
  set document(title: "The Agentic Crew", author: "Rasmus Bornhøft Schlünsen")

  set page(
    paper: "a5",
    margin: (top: 0.82in, bottom: 0.78in, x: 0.68in),
    header-ascent: 38%,
    footer-descent: 38%,
    header: context {
      let pg = here().page()
      let openers = query(heading.where(level: 1)).filter(h => h.location().page() == pg)
      if pg > 1 and openers.len() == 0 {
        let prev = query(heading.where(level: 1).before(here()))
        let chapter = if prev.len() > 0 { prev.last() } else { none }
        set text(font: sans, size: 6.4pt, tracking: 1.1pt, fill: muted)
        grid(
          columns: (1fr, auto),
          upper[The Agentic Crew],
          if chapter != none {
            let label = if chapter.numbering != none {
              str(counter(heading).at(chapter.location()).first()) + "  ·  "
            } else if is-appendix(chapter) { upper(chapter.supplement) + "  ·  " } else { "" }
            upper[#label#chapter.body]
          },
        )
        v(-3.5pt)
        line(length: 100%, stroke: 0.35pt + rule)
      }
    },
    footer: context {
      let pg = here().page()
      if pg > 1 {
        set align(center)
        set text(font: sans, size: 7pt, fill: muted, tracking: 0.6pt)
        counter(page).display()
      }
    },
  )

  set text(font: serif, size: 9.8pt, fill: ink, lang: "en", region: "gb", hyphenate: true, number-type: "old-style")
  set par(justify: true, leading: 0.72em, spacing: 1.05em, linebreaks: "optimized")
  show strong: set text(weight: 600)
  show link: set text(fill: brass)

  // Lists
  set list(marker: text(fill: brass-light, size: 0.8em, baseline: -0.1em)[■], indent: 0.2em, body-indent: 0.7em, spacing: 0.75em)
  set enum(numbering: n => text(font: sans, size: 0.78em, weight: 600, fill: brass)[#n.], indent: 0.1em, body-indent: 0.7em, spacing: 0.75em)

  // Code
  show raw: set text(font: mono, features: (calt: 0))
  set raw(theme: "assets/code-theme.tmTheme")
  show raw.where(block: false): it => box(
    fill: tint, outset: (x: 1.6pt, y: 2pt), radius: 2pt,
    text(size: 0.84em, fill: ink.lighten(10%), it),
  )
  show raw.where(block: true): it => block(
    width: 100%, fill: tint, inset: (left: 10pt, right: 8pt, y: 8pt), radius: (right: 3pt),
    stroke: (left: 1.6pt + brass-light), above: 1.1em, below: 1.2em, breakable: true,
    { set par(justify: false, leading: 0.55em); set text(size: 7.1pt, number-type: "lining"); it },
  )

  // Figures
  show figure: set block(above: 1.4em, below: 1.4em)
  show figure.caption: it => {
    set text(font: serif, style: "italic", size: 8pt, fill: muted)
    v(0.2em)
    it.body
  }
  show image: it => box(clip: true, radius: 3pt, it)

  // Headings
  set heading(numbering: "1.1")
  show heading: set text(fill: ink, hyphenate: false)
  show heading: set par(justify: false)

  show heading.where(level: 1): it => {
    if is-part(it) {
      // Rendered inside a part() page.
      text(font: display, weight: 400, size: 30pt, fill: cream, tracking: -0.4pt, it.body)
    } else {
      pagebreak(weak: true)
      v(0.95in)
      if it.numbering != none {
        label-text[Chapter]
        v(-0.2em)
        text(font: display, weight: 300, size: 50pt, fill: brass-light, number-type: "lining", context counter(heading).display("1"))
        v(0.15em)
      } else if is-appendix(it) {
        label-text(it.supplement)
        v(0.55em)
      } else {
        v(1.2em)
      }
      block(width: 92%, text(font: display, weight: 400, size: 23pt, tracking: -0.3pt, it.body))
      v(0.5em)
      line(length: 1.6cm, stroke: 0.8pt + brass-light)
      v(1.9em)
    }
  }

  show heading.where(level: 2): it => {
    set text(font: display, weight: 500, size: 12.6pt, tracking: -0.1pt)
    block(above: 2em, below: 0.85em, sticky: true, {
      if it.numbering != none {
        box(width: 2.1em, text(font: sans, weight: 500, size: 7.2pt, fill: brass, tracking: 0.4pt, number-type: "lining", counter(heading).display(it.numbering)))
      }
      it.body
    })
  }

  show heading.where(level: 3): it => block(above: 1.7em, below: 0.95em, sticky: true,
    text(font: sans, weight: 600, size: 8.6pt, tracking: 0.2pt, fill: ink, it.body))

  // Table of contents
  show outline.entry: it => {
    let el = it.element
    if el.func() != heading { return it }
    if el.level == 1 and is-part(el) {
      v(1.1em, weak: true)
      block(below: 0.55em, grid(columns: (1fr,),
        label-text(if el.supplement == [] [#el.body] else [#el.supplement · #el.body], size: 6.8pt, tracking: 1.5pt)))
    } else if el.level == 1 {
      let num = if el.numbering != none { str(counter(heading).at(el.location()).first()) } else if is-appendix(el) and el.supplement.has("text") { el.supplement.text.slice(-1) } else { "" }
      v(0.55em, weak: true)
      link(el.location(), grid(
        columns: (1.6em, 1fr, auto), column-gutter: 0.3em,
        text(font: display, weight: 400, size: 10.2pt, fill: brass, number-type: "lining", num),
        text(font: display, weight: 400, size: 10.2pt, fill: ink, el.body),
        text(font: sans, size: 7.4pt, fill: muted, it.page()),
      ))
    } else {
      link(el.location(), grid(
        columns: (1.6em, 1fr, auto), column-gutter: 0.3em,
        [],
        text(size: 8.2pt, fill: muted, el.body),
        text(font: sans, size: 7pt, fill: muted.lighten(20%), it.page()),
      ))
    }
  }

  body
}
