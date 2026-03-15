# The Agentic Engineer — build commands

# Build the book to PDF
build:
    typst compile book.typ build/the-agentic-engineer.pdf

# Watch for changes and rebuild automatically
watch:
    typst watch book.typ build/the-agentic-engineer.pdf

# Open the built PDF (macOS)
open: build
    open build/the-agentic-engineer.pdf

# Create a new chapter file
new-chapter name:
    #!/usr/bin/env bash
    next=$(ls chapters/ | sort -n | tail -1 | grep -oE '^[0-9]+' | awk '{printf "%02d", $1+1}')
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

# Deploy website to production
deploy:
    cd website && npm run build
    rsync -avz --delete website/dist/ root@theagenticcrew.com:/var/www/theagenticcrew.com/
    @echo "Deployed to https://theagenticcrew.com"

# Word count (approximate)
wc:
    @cat chapters/*.typ | wc -w | xargs echo "Approximate word count:"
