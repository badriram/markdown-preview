# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Custom macOS Automator actions. Primary use case: generate PDF previews of Markdown files for Quick Look viewing and printing in Finder.

## Installation

```bash
brew tap badriram/tools
brew install markdown-preview
```

This installs for the current user. Other users on the same Mac need to run:
```bash
markdown-preview --install
```

For system-wide install (all users):
```bash
sudo markdown-preview --install-system
```

## Usage

**From Finder:** Right-click `.md` file → Quick Actions → Markdown Preview

**From terminal:**
```bash
markdown-preview file.md              # Preview (PDF in temp, opens Preview.app)
markdown-preview file.md output.pdf   # Save to specific path
```

## Architecture

```
automatorActions/
├── scripts/
│   └── md-to-pdf.sh              # Main script (pandoc → weasyprint)
├── styles/
│   └── print.css                 # Print-friendly CSS
├── workflows/
│   └── Markdown Preview.workflow # Automator Quick Action bundle
└── homebrew-tap/
    └── Formula/markdown-preview.rb
```

### Conversion Flow

1. `pandoc` converts Markdown → standalone HTML with embedded CSS
2. `weasyprint` converts HTML → PDF
3. PDF saved to `$TMPDIR` (temp, auto-cleaned) and opens in Preview.app

### Install Locations

| Component | Location | Scope |
|-----------|----------|-------|
| Script, styles | `/opt/homebrew/` | System-wide |
| Quick Action | `~/Library/Services/` | Per-user |
| Quick Action | `/Library/Services/` | System-wide (with `--install-system`) |

## Development

### Test locally

```bash
brew install pandoc weasyprint
./scripts/md-to-pdf.sh ./CLAUDE.md
./scripts/md-to-pdf.sh --install
```

### Publishing the Homebrew Tap

1. Create GitHub repo `badriram/homebrew-tools`
2. Copy `homebrew-tap/Formula/markdown-preview.rb` to the repo
3. Create release tag `v0.1.0` in this repo (automatorActions)
4. Get SHA256: `curl -sL https://github.com/badriram/automatorActions/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256`
5. Update formula with the SHA256
