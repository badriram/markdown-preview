class MarkdownPreview < Formula
  desc "Generate PDF previews of Markdown files for macOS Finder Quick Look"
  homepage "https://github.com/badriram/markdown-preview"
  url "https://github.com/badriram/markdown-preview/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "884402ba436077cf9cf5f79cb79d9705861d35c4afbe13185a971e705efe5ec6"
  license "MIT"

  depends_on "pandoc"
  depends_on "weasyprint"
  depends_on :macos

  def install
    # Install main script
    bin.install "scripts/md-to-pdf.sh" => "markdown-preview"

    # Install styles
    (share/"markdown-preview/styles").install "styles/print.css"

    # Install workflow bundle (for user installation)
    (share/"markdown-preview").install "workflows/Markdown Preview.workflow"

    # Update script paths for Homebrew installation
    inreplace bin/"markdown-preview" do |s|
      s.gsub! 'STYLES_DIR="$SCRIPT_DIR/../styles"',
              "STYLES_DIR=\"#{share}/markdown-preview/styles\""
    end
  end

  def post_install
    # Install Quick Action for current user
    system "#{bin}/markdown-preview", "--install"
  end

  def caveats
    <<~EOS
      Quick Action installed for current user.

      Usage:
        • Right-click any .md file in Finder → Quick Actions → Markdown Preview
        • Or from terminal: markdown-preview /path/to/file.md

      Other users on this Mac need to run:
        markdown-preview --install

      For system-wide install (all users):
        sudo markdown-preview --install-system
    EOS
  end

  test do
    (testpath/"test.md").write("# Hello World\n\nThis is a test.")
    system "#{bin}/markdown-preview", testpath/"test.md", testpath/"test.pdf"
    assert_predicate testpath/"test.pdf", :exist?
  end
end
