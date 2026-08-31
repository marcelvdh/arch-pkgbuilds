#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(bash "$dir/../scripts/apt-latest.sh" \
  https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 \
  "$dir/../keys/anthropic-apt.asc" claude-desktop)"
exec bash "$dir/../scripts/set-pkgver.sh" "$ver"
