#!/usr/bin/env bash
# Bump claude-desktop's PKGBUILD to the latest version, print it.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(bash "$dir/../scripts/apt-latest.sh" \
  https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 \
  "$dir/../keys/anthropic-apt.asc" claude-desktop)"
exec bash "$dir/../scripts/set-pkgver.sh" "$ver"
