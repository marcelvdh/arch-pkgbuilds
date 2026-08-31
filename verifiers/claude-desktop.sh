#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's .deb
# checksum against Anthropic's signed apt metadata.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
want="$(bash "$dir/../scripts/apt-sha256.sh" \
  https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 \
  "$dir/../keys/anthropic-apt.asc" \
  "claude-desktop_${ver}_amd64.deb")"
exec bash "$dir/../scripts/check-sum.sh" "claude-desktop $ver" "$want"
