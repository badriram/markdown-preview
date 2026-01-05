#!/bin/bash
# Convert Markdown file to PDF for Quick Look preview in Finder
# Usage: markdown-preview <input.md> [output.pdf]
#        markdown-preview --install

set -euo pipefail

# Add Homebrew to PATH (needed for Automator)
export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STYLES_DIR="$SCRIPT_DIR/../styles"
CSS_FILE="$STYLES_DIR/print.css"

# Handle install flags
if [[ "${1:-}" == "--install" || "${1:-}" == "--install-system" ]]; then
    WORKFLOW_SRC="$SCRIPT_DIR/../share/markdown-preview/Markdown Preview.workflow"

    if [[ ! -d "$WORKFLOW_SRC" ]]; then
        echo "Error: Workflow not found. Is markdown-preview installed via Homebrew?" >&2
        exit 1
    fi

    if [[ "${1:-}" == "--install-system" ]]; then
        # System-wide install (all users)
        SERVICES_DIR="/Library/Services"
        if [[ ! -w "$SERVICES_DIR" ]]; then
            echo "System-wide install requires sudo:"
            echo "  sudo markdown-preview --install-system"
            exit 1
        fi
    else
        # Per-user install
        SERVICES_DIR="$HOME/Library/Services"
    fi

    mkdir -p "$SERVICES_DIR"

    # Remove old version (ignore errors from permission issues)
    rm -rf "$SERVICES_DIR/Markdown Preview.workflow" 2>/dev/null || true

    # Copy workflow (force overwrite)
    cp -Rf "$WORKFLOW_SRC" "$SERVICES_DIR/"

    # Refresh services menu
    /System/Library/CoreServices/pbs -update 2>/dev/null || true

    if [[ "${1:-}" == "--install-system" ]]; then
        echo "Installed system-wide! All users can now use: Right-click .md → Quick Actions → Markdown Preview"
    else
        echo "Installed! Right-click any .md file in Finder → Quick Actions → Markdown Preview"
    fi
    exit 0
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: markdown-preview <input.md> [output.pdf]" >&2
    echo "       markdown-preview --install         # Install for current user" >&2
    echo "       sudo markdown-preview --install-system  # Install for all users" >&2
    exit 1
fi

INPUT_FILE="$1"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File not found: $INPUT_FILE" >&2
    exit 1
fi

# Get absolute path to input file
INPUT_FILE="$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")"
INPUT_DIR="$(dirname "$INPUT_FILE")"

# Output PDF: always to TMPDIR for preview (no file left behind)
# Unless explicit output path is provided
if [[ $# -ge 2 ]]; then
    OUTPUT_FILE="$2"
else
    OUTPUT_FILE="$TMPDIR/$(basename "$INPUT_FILE" .md).pdf"
fi

# Check for dependencies
if ! command -v pandoc &> /dev/null; then
    osascript -e 'display dialog "pandoc is not installed. Run: brew install badriram/tools/markdown-preview" buttons {"OK"} default button "OK" with icon stop'
    exit 1
fi

if ! command -v weasyprint &> /dev/null; then
    osascript -e 'display dialog "weasyprint is not installed. Run: brew install badriram/tools/markdown-preview" buttons {"OK"} default button "OK" with icon stop'
    exit 1
fi

# Convert markdown to HTML, then HTML to PDF
TEMP_HTML=$(mktemp /tmp/md-preview.XXXXXX.html)
trap "rm -f '$TEMP_HTML'" EXIT

# Pandoc: markdown -> standalone HTML with embedded CSS
pandoc "$INPUT_FILE" \
    --standalone \
    --embed-resources \
    --css="$CSS_FILE" \
    --metadata title="$(basename "$INPUT_FILE" .md)" \
    -o "$TEMP_HTML"

# Weasyprint: HTML -> PDF (suppress CSS warnings)
weasyprint "$TEMP_HTML" "$OUTPUT_FILE" 2>/dev/null

# Open in Preview.app for viewing/printing
open "$OUTPUT_FILE"
