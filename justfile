# The Agentic Engineer — build commands

# Read current revision
revision := `cat REVISION`

# Build the English book to PDF (with revision stamp)
build:
    typst compile --input revision={{revision}} book.typ build/the-agentic-crew.pdf

# Build Catalan edition
build-ca:
    typst compile --input revision={{revision}} book-ca.typ build/the-agentic-crew-ca.pdf

# Build Danish edition
build-da:
    typst compile --input revision={{revision}} book-da.typ build/the-agentic-crew-da.pdf

# Build Spanish edition
build-es:
    typst compile --input revision={{revision}} book-es.typ build/the-agentic-crew-es.pdf

# Build English kids' edition
build-kids:
    typst compile --input revision={{revision}} book-kids.typ build/the-agentic-crew-kids.pdf

# Build Spanish kids' edition
build-kids-es:
    typst compile --input revision={{revision}} book-kids-es.typ build/the-agentic-crew-kids-es.pdf

# Build Catalan kids' edition
build-kids-ca:
    typst compile --input revision={{revision}} book-kids-ca.typ build/the-agentic-crew-kids-ca.pdf

# Build Danish kids' edition
build-kids-da:
    typst compile --input revision={{revision}} book-kids-da.typ build/the-agentic-crew-kids-da.pdf

# Build English crew member's guide
build-crew:
    typst compile --input revision={{revision}} book-crew.typ build/the-agentic-crew-crew.pdf

# Build Catalan crew member's guide
build-crew-ca:
    typst compile --input revision={{revision}} book-crew-ca.typ build/the-agentic-crew-crew-ca.pdf

# Build all crew editions
build-crew-all: build-crew build-crew-ca

# Build all kids' editions
build-kids-all: build-kids build-kids-es build-kids-ca build-kids-da

# Build all PDFs (adult + kids + crew)
build-all: build build-ca build-da build-es build-kids-all build-crew-all

# Watch for changes and rebuild automatically
watch:
    typst watch --input revision={{revision}} book.typ build/the-agentic-crew.pdf

# Open the built PDF (macOS)
open: build
    open build/the-agentic-crew.pdf

# Open the kids' edition PDF (macOS)
open-kids: build-kids
    open build/the-agentic-crew-kids.pdf

# Open the crew member's guide PDF (macOS)
open-crew: build-crew
    open build/the-agentic-crew-crew.pdf

# Create a new chapter file
new-chapter name:
    #!/usr/bin/env bash
    next=$(ls chapters/*.typ | sort -n | tail -1 | grep -oE '[0-9]+' | head -1 | awk '{printf "%02d", $1+1}')
    file="chapters/${next}-{{name}}.typ"
    echo "= {{name}}" > "$file"
    echo "" >> "$file"
    echo "TODO: Write this chapter." >> "$file"
    echo "Created $file"
    echo "Don't forget to add: #include \"$file\" to book.typ"

# Clean build artifacts
clean:
    rm -rf build/*

# Start the website dev server
site:
    cd website && npm run dev

# Build the website for production
site-build:
    cd website && npm run build

# Deploy website to production (rebuilds all editions + site, archives revision)
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    rev=$(cat REVISION)
    echo "Deploying revision $rev..."

    # Build all PDFs with revision stamp
    typst compile --input revision="$rev" book.typ build/the-agentic-crew.pdf
    typst compile --input revision="$rev" book-ca.typ build/the-agentic-crew-ca.pdf
    typst compile --input revision="$rev" book-da.typ build/the-agentic-crew-da.pdf
    typst compile --input revision="$rev" book-es.typ build/the-agentic-crew-es.pdf

    # Build crew member's guide PDFs
    typst compile --input revision="$rev" book-crew.typ build/the-agentic-crew-crew.pdf
    typst compile --input revision="$rev" book-crew-ca.typ build/the-agentic-crew-crew-ca.pdf

    # Build all kids' PDFs
    typst compile --input revision="$rev" book-kids.typ build/the-agentic-crew-kids.pdf
    typst compile --input revision="$rev" book-kids-es.typ build/the-agentic-crew-kids-es.pdf
    typst compile --input revision="$rev" book-kids-ca.typ build/the-agentic-crew-kids-ca.pdf
    typst compile --input revision="$rev" book-kids-da.typ build/the-agentic-crew-kids-da.pdf

    # Build all EPUBs
    pandoc epub.typ -f typst -t epub3 -o build/the-agentic-crew.epub \
        --metadata title="The Agentic Crew" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=en \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-ca.typ -f typst -t epub3 -o build/the-agentic-crew-ca.epub \
        --metadata title="La Tripulació Agèntica" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=ca \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-da.typ -f typst -t epub3 -o build/the-agentic-crew-da.epub \
        --metadata title="Det Agentiske Mandskab" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=da \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-es.typ -f typst -t epub3 -o build/the-agentic-crew-es.epub \
        --metadata title="La Tripulación Agéntica" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=es \
        --toc --toc-depth=2 --split-level=1

    # Build all kids' EPUBs
    pandoc epub-kids.typ -f typst -t epub3 -o build/the-agentic-crew-kids.epub \
        --metadata title="The Agentic Crew: A Kids' Guide" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=en \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-kids-es.typ -f typst -t epub3 -o build/the-agentic-crew-kids-es.epub \
        --metadata title="La Tripulación Agéntica: Guía para Niños" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=es \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-kids-ca.typ -f typst -t epub3 -o build/the-agentic-crew-kids-ca.epub \
        --metadata title="La Tripulació Agèntica: Guia per a Nens" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=ca \
        --toc --toc-depth=2 --split-level=1

    pandoc epub-kids-da.typ -f typst -t epub3 -o build/the-agentic-crew-kids-da.epub \
        --metadata title="Det Agentiske Mandskab: Børneguide" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=da \
        --toc --toc-depth=2 --split-level=1

    # Copy current builds to website public
    cp build/the-agentic-crew.pdf website/public/the-agentic-crew.pdf
    cp build/the-agentic-crew.epub website/public/the-agentic-crew.epub
    cp build/the-agentic-crew-ca.pdf website/public/the-agentic-crew-ca.pdf
    cp build/the-agentic-crew-ca.epub website/public/the-agentic-crew-ca.epub
    cp build/the-agentic-crew-da.pdf website/public/the-agentic-crew-da.pdf
    cp build/the-agentic-crew-da.epub website/public/the-agentic-crew-da.epub
    cp build/the-agentic-crew-es.pdf website/public/the-agentic-crew-es.pdf
    cp build/the-agentic-crew-es.epub website/public/the-agentic-crew-es.epub
    cp build/the-agentic-crew-kids.pdf website/public/the-agentic-crew-kids.pdf
    cp build/the-agentic-crew-kids.epub website/public/the-agentic-crew-kids.epub
    cp build/the-agentic-crew-kids-es.pdf website/public/the-agentic-crew-kids-es.pdf
    cp build/the-agentic-crew-kids-es.epub website/public/the-agentic-crew-kids-es.epub
    cp build/the-agentic-crew-kids-ca.pdf website/public/the-agentic-crew-kids-ca.pdf
    cp build/the-agentic-crew-kids-ca.epub website/public/the-agentic-crew-kids-ca.epub
    cp build/the-agentic-crew-kids-da.pdf website/public/the-agentic-crew-kids-da.pdf
    cp build/the-agentic-crew-kids-da.epub website/public/the-agentic-crew-kids-da.epub
    cp build/the-agentic-crew-crew.pdf website/public/the-agentic-crew-crew.pdf
    cp build/the-agentic-crew-crew-ca.pdf website/public/the-agentic-crew-crew-ca.pdf

    # Archive revisions
    mkdir -p website/public/revisions
    cp build/the-agentic-crew.pdf "website/public/revisions/the-agentic-crew-rev${rev}.pdf"
    cp build/the-agentic-crew.epub "website/public/revisions/the-agentic-crew-rev${rev}.epub"
    cp build/the-agentic-crew-ca.pdf "website/public/revisions/the-agentic-crew-ca-rev${rev}.pdf"
    cp build/the-agentic-crew-ca.epub "website/public/revisions/the-agentic-crew-ca-rev${rev}.epub"
    cp build/the-agentic-crew-da.pdf "website/public/revisions/the-agentic-crew-da-rev${rev}.pdf"
    cp build/the-agentic-crew-da.epub "website/public/revisions/the-agentic-crew-da-rev${rev}.epub"
    cp build/the-agentic-crew-es.pdf "website/public/revisions/the-agentic-crew-es-rev${rev}.pdf"
    cp build/the-agentic-crew-es.epub "website/public/revisions/the-agentic-crew-es-rev${rev}.epub"
    cp build/the-agentic-crew-kids.pdf "website/public/revisions/the-agentic-crew-kids-rev${rev}.pdf"
    cp build/the-agentic-crew-kids.epub "website/public/revisions/the-agentic-crew-kids-rev${rev}.epub"
    cp build/the-agentic-crew-kids-es.pdf "website/public/revisions/the-agentic-crew-kids-es-rev${rev}.pdf"
    cp build/the-agentic-crew-kids-es.epub "website/public/revisions/the-agentic-crew-kids-es-rev${rev}.epub"
    cp build/the-agentic-crew-kids-ca.pdf "website/public/revisions/the-agentic-crew-kids-ca-rev${rev}.pdf"
    cp build/the-agentic-crew-kids-ca.epub "website/public/revisions/the-agentic-crew-kids-ca-rev${rev}.epub"
    cp build/the-agentic-crew-kids-da.pdf "website/public/revisions/the-agentic-crew-kids-da-rev${rev}.pdf"
    cp build/the-agentic-crew-kids-da.epub "website/public/revisions/the-agentic-crew-kids-da-rev${rev}.epub"
    cp build/the-agentic-crew-crew.pdf "website/public/revisions/the-agentic-crew-crew-rev${rev}.pdf"
    cp build/the-agentic-crew-crew-ca.pdf "website/public/revisions/the-agentic-crew-crew-ca-rev${rev}.pdf"

    # Build website
    cd website && npm run build && cd ..

    # Deploy
    rsync -avz --delete website/dist/ root@theagenticcrew.com:/var/www/theagenticcrew.com/

    # Increment revision for next deploy
    echo $((rev + 1)) > REVISION

    echo "Deployed revision $rev to https://theagenticcrew.com"
    echo "Archived at /revisions/"

# Build the English book to EPUB
epub:
    pandoc epub.typ -f typst -t epub3 -o build/the-agentic-crew.epub \
        --metadata title="The Agentic Crew" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=en \
        --toc --toc-depth=2 --split-level=1
    @echo "Built build/the-agentic-crew.epub"

# Build all formats (PDF + EPUB, all languages)
all: build-all epub

# Word count (approximate)
wc:
    @cat chapters/*.typ | wc -w | xargs echo "Approximate word count:"
