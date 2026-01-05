#!/bin/bash
# Install markdown-preview Quick Action for Finder
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_NAME="Markdown Preview.workflow"
SERVICES_DIR="$HOME/Library/Services"

echo "Installing Markdown Preview Quick Action..."

# Create Services directory if it doesn't exist
mkdir -p "$SERVICES_DIR"

# Remove old version if exists
if [[ -d "$SERVICES_DIR/$WORKFLOW_NAME" ]]; then
    rm -rf "$SERVICES_DIR/$WORKFLOW_NAME"
    echo "  Removed old version"
fi

# Copy workflow
cp -r "$SCRIPT_DIR/workflows/$WORKFLOW_NAME" "$SERVICES_DIR/"
echo "  Installed to $SERVICES_DIR/$WORKFLOW_NAME"

# Refresh services menu
/System/Library/CoreServices/pbs -update
echo "  Refreshed services menu"

echo ""
echo "Done! Right-click any .md file in Finder → Quick Actions → Markdown Preview"
