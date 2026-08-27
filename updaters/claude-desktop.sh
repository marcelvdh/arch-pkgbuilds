#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
set -euo pipefail

ver="$(bash "$(dirname "$0")/../scripts/apt-latest.sh" https://downloads.claude.ai/claude-desktop/apt/stable stable claude-desktop)"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
