# CLAUDE.md

markdown-preview: a macOS Finder Quick Action that previews Markdown as PDF (pandoc → WeasyPrint).
User-facing install and usage live in README.md.

## Layout

```
scripts/md-to-pdf.sh               # the tool; installed as `markdown-preview`
styles/print.css                   # print CSS embedded into the HTML
workflows/Markdown Preview.workflow  # Automator Quick Action, copied to ~/Library/Services
.github/workflows/release.yml      # bumps the Homebrew formula on a vX.Y.Z tag
```

Flow: pandoc renders standalone HTML with the CSS, WeasyPrint renders the PDF into `$TMPDIR` (or the
given output path), then `open` shows it in Preview.

## The formula is coupled to this repo

`Formula/markdown-preview.rb` lives in the tap repo `badriram/homebrew-tools`, shared with DockPeek's
cask and bonsai. It installs those three paths verbatim and `inreplace`s the exact line
`STYLES_DIR="$SCRIPT_DIR/../styles"` in the script; `inreplace` aborts the install if that line
changes. `release.yml` only bumps `url` and `sha256`, so any rename, new file or edit to that line
needs a matching hand edit to the formula in `homebrew-tools` before tagging. Check the formula
whenever you touch the layout.

## Test locally

```sh
brew install pandoc weasyprint
./scripts/md-to-pdf.sh ./README.md
./scripts/md-to-pdf.sh --install     # Quick Action for the current user
```

## Releasing

Tag `vX.Y.Z` and push. `release.yml` validates the tag, hashes GitHub's source tarball for it, and
commits the new `url`/`sha256` to the formula in `badriram/homebrew-tools`.

- Tags matching `v*` can't be moved or deleted (ruleset), because the formula installs the tag's
  tarball: a wrong tag gets fixed by tagging the next version.
- Actions are limited to GitHub-owned actions pinned to a commit SHA; Dependabot proposes bumps.
  New steps must follow that, or the run is rejected.
- Expressions like `${{ github.ref_name }}` reach shell steps through `env:`, never inline in
  `run:` (script injection with the tap token in scope).
- `HOMEBREW_TAP_TOKEN` (repo secret) must be a fine-grained token limited to Contents read/write on
  `homebrew-tools`. Fine-grained tokens expire: when the formula stops bumping, check it first.

## Public repo hygiene

Commits use `badriram <1929515+badriram@users.noreply.github.com>`. Keep the owner's full name,
personal email and Apple Developer account details out of new commits and files. Older history
still carries them; that was a deliberate choice, not something to rewrite.
