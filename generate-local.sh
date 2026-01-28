#!/bin/bash

# Generate Live Sample project with local source code dependencies
#
# This script generates Xcode projects for the sample app with local dependencies:
#   - sendbird-live-sample-ios -> live-ios (local)
#   - live-ios -> calls-core-ios (local)
#
# Can be run from any directory.

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parent directory containing all projects
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Generating Live Sample project with local dependencies..."
echo ""

# Generate live-ios project with local calls-core-ios
echo "[1/2] Generating live-ios project (with local calls-core-ios)..."
cd "$PROJECT_ROOT/live-ios"
xcodegen generate --spec project-local.yml
echo "Done: live-ios"
echo ""

# Generate sendbird-live-sample-ios project with local live-ios
echo "[2/2] Generating sendbird-live-sample-ios project (with local live-ios)..."
cd "$SCRIPT_DIR"
xcodegen generate --spec project-local.yml
echo "Done: sendbird-live-sample-ios"
echo ""

echo "All projects generated successfully!"
echo ""
echo "Open the sample app:"
echo "  open $SCRIPT_DIR/VideoLive.xcodeproj"
