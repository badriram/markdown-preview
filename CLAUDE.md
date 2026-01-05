# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOS Finder Quick Action to preview Markdown files as PDF using pandoc + weasyprint.

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
markdown-preview/
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
3. Create release tag in this repo: `git tag vX.Y.Z && git push origin vX.Y.Z`
4. Get SHA256: `curl -sL https://github.com/badriram/markdown-preview/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`
5. Update formula with the SHA256
