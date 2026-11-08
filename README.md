# Markdown Preview

A macOS Finder Quick Action that previews Markdown files as PDF, using
[pandoc](https://pandoc.org) and [WeasyPrint](https://weasyprint.org).

## Install

```sh
brew tap badriram/tools
brew install markdown-preview
```

This installs the Quick Action for the current user. Other users on the same Mac run
`markdown-preview --install`; for all users, `sudo markdown-preview --install-system`.

## Use

- **Finder:** right-click a `.md` file → Quick Actions → **Markdown Preview**.
- **Terminal:**
  ```sh
  markdown-preview file.md              # PDF in a temp folder, opened in Preview
  markdown-preview file.md output.pdf   # save to a specific path
  ```

## How it works

pandoc turns the Markdown into a standalone HTML page with print-friendly CSS
(`styles/print.css`), then WeasyPrint renders it to PDF. Previews go to `$TMPDIR` and are cleaned
up by macOS.

## License

MIT, see [LICENSE](LICENSE).
