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

# Build English crew member's guide
build-crew:
    typst compile --input revision={{revision}} book-crew.typ build/the-agentic-crew-crew.pdf

# Build Catalan crew member's guide
build-crew-ca:
    typst compile --input revision={{revision}} book-crew-ca.typ build/the-agentic-crew-crew-ca.pdf

# Build all crew editions
build-crew-all: build-crew build-crew-ca

# Build all PDFs (adult + crew)
build-all: build build-ca build-da build-es build-crew-all

# Watch for changes and rebuild automatically
watch:
    typst watch --input revision={{revision}} book.typ build/the-agentic-crew.pdf

# Open the built PDF (macOS)
open: build
    open build/the-agentic-crew.pdf

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

# Quick deploy — website only, no book rebuild, compressed rsync
deploy-fast:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Fast deploy: website only..."
    cd website && npm run build && cd ..
    rsync -az --delete --compress-level=9 --progress website/dist/ root@theagenticcrew.com:/var/www/theagenticcrew.com/
    echo "Deployed website to https://theagenticcrew.com"

# Deploy website to production (rebuilds all editions + site, archives revision)
deploy:
    #!/usr/bin/env bash
    set -euo pipefail

    rev=$(cat REVISION)
    echo "Deploying revision $rev..."

    # Build all PDFs in parallel
    typst compile --input revision="$rev" book.typ build/the-agentic-crew.pdf &
    typst compile --input revision="$rev" book-ca.typ build/the-agentic-crew-ca.pdf &
    typst compile --input revision="$rev" book-da.typ build/the-agentic-crew-da.pdf &
    typst compile --input revision="$rev" book-es.typ build/the-agentic-crew-es.pdf &
    typst compile --input revision="$rev" book-crew.typ build/the-agentic-crew-crew.pdf &
    typst compile --input revision="$rev" book-crew-ca.typ build/the-agentic-crew-crew-ca.pdf &
    wait
    echo "PDFs built."

    # Build all EPUBs in parallel
    pandoc epub.typ -f typst -t epub3 -o build/the-agentic-crew.epub \
        --metadata title="The Agentic Crew" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=en \
        --toc --toc-depth=2 --split-level=1 &

    pandoc epub-ca.typ -f typst -t epub3 -o build/the-agentic-crew-ca.epub \
        --metadata title="La Tripulació Agèntica" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=ca \
        --toc --toc-depth=2 --split-level=1 &

    pandoc epub-da.typ -f typst -t epub3 -o build/the-agentic-crew-da.epub \
        --metadata title="Det Agentiske Mandskab" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=da \
        --toc --toc-depth=2 --split-level=1 &

    pandoc epub-es.typ -f typst -t epub3 -o build/the-agentic-crew-es.epub \
        --metadata title="La Tripulación Agéntica" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=es \
        --toc --toc-depth=2 --split-level=1 &

    pandoc epub-crew.typ -f typst -t epub3 -o build/the-agentic-crew-crew.epub \
        --metadata title="The Agentic Crew: Crew Member's Guide" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=en \
        --toc --toc-depth=2 --split-level=1 &

    pandoc epub-crew-ca.typ -f typst -t epub3 -o build/the-agentic-crew-crew-ca.epub \
        --metadata "title=La Tripulacio Agentica: Guia del Tripulant" \
        --metadata "author=Rasmus Bornhøft Schlünsen" \
        --metadata lang=ca \
        --toc --toc-depth=2 --split-level=1 &
    wait
    echo "EPUBs built."

    # Copy all builds to website public
    cp build/the-agentic-crew.pdf website/public/the-agentic-crew.pdf
    cp build/the-agentic-crew.epub website/public/the-agentic-crew.epub
    cp build/the-agentic-crew-ca.pdf website/public/the-agentic-crew-ca.pdf
    cp build/the-agentic-crew-ca.epub website/public/the-agentic-crew-ca.epub
    cp build/the-agentic-crew-da.pdf website/public/the-agentic-crew-da.pdf
    cp build/the-agentic-crew-da.epub website/public/the-agentic-crew-da.epub
    cp build/the-agentic-crew-es.pdf website/public/the-agentic-crew-es.pdf
    cp build/the-agentic-crew-es.epub website/public/the-agentic-crew-es.epub
    cp build/the-agentic-crew-crew.pdf website/public/the-agentic-crew-crew.pdf
    cp build/the-agentic-crew-crew.epub website/public/the-agentic-crew-crew.epub
    cp build/the-agentic-crew-crew-ca.pdf website/public/the-agentic-crew-crew-ca.pdf
    cp build/the-agentic-crew-crew-ca.epub website/public/the-agentic-crew-crew-ca.epub

    # Archive revisions locally
    mkdir -p revisions
    for f in the-agentic-crew the-agentic-crew-ca the-agentic-crew-da the-agentic-crew-es the-agentic-crew-crew the-agentic-crew-crew-ca; do
        cp "build/${f}.pdf" "revisions/${f}-rev${rev}.pdf" 2>/dev/null || true
        cp "build/${f}.epub" "revisions/${f}-rev${rev}.epub" 2>/dev/null || true
    done

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
