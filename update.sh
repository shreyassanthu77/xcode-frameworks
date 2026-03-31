#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SDK_BASE="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs"

if [ ! -d "$SDK_BASE" ]; then
    echo "error: Xcode SDK directory not found at $SDK_BASE" >&2
    echo "Ensure Xcode is installed." >&2
    exit 1
fi

# Find the latest versioned SDK (e.g. MacOSX15.0.sdk), preferring versioned over the MacOSX.sdk symlink
LATEST_SDK=$(ls -d "$SDK_BASE"/MacOSX[0-9]*.sdk 2>/dev/null | sort -V | tail -1)
if [ -z "$LATEST_SDK" ]; then
    # Fall back to the generic symlink
    LATEST_SDK="$SDK_BASE/MacOSX.sdk"
fi

if [ ! -d "$LATEST_SDK" ]; then
    echo "error: No macOS SDK found in $SDK_BASE" >&2
    exit 1
fi

echo "Detected SDK: $LATEST_SDK"

CURRENT=$(grep "^sdk=" generate.sh | sed "s/sdk='\\(.*\\)'/\\1/")
echo "Current SDK in generate.sh: $CURRENT"

if [ "$CURRENT" = "$LATEST_SDK" ]; then
    echo "Already up to date."
    exit 0
fi

sed -i.bak "s|^sdk=.*|sdk='$LATEST_SDK'|" generate.sh && rm -f generate.sh.bak
echo "Updated generate.sh. Run ./generate.sh to regenerate."
