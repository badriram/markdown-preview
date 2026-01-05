class MarkdownPreview < Formula
  desc "Generate PDF previews of Markdown files for macOS Finder Quick Look"
  homepage "https://github.com/badriram/markdown-preview"
  url "https://github.com/badriram/markdown-preview/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "f4a900b576952230ec4238892ecc90c48f4036a2c5532f0266d8e108e87ca981"
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
    # Try to install Quick Action for current user (may fail due to macOS sandboxing)
    if !system("#{bin}/markdown-preview", "--install")
      opoo "Could not auto-install Quick Action. Run manually: markdown-preview --install"
    end
  end

  def caveats
    <<~EOS
      If the Quick Action wasn't installed automatically, run:
        markdown-preview --install

      Usage:
        • Right-click any .md file in Finder → Quick Actions → Markdown Preview
        • Or from terminal: markdown-preview /path/to/file.md

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
