#!/usr/bin/env bash
# Check claude-desktop's pinned sha256 against Anthropic's signed apt metadata.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
want="$(apt_sha256 https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 anthropic-apt \
  "claude-desktop_${version}_amd64.deb")"

# An apt index lists only the current version, so a missing entry means this
# release was superseded, not that the check failed.
[ -n "$want" ] || { echo "claude-desktop $version: superseded, no longer in the apt index"; exit 0; }

check_sum "claude-desktop $version" "$want"
