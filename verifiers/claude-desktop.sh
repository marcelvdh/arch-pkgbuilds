#!/usr/bin/env bash
# Check claude-desktop's pinned sha256 against Anthropic's signed apt metadata.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
want="$(apt_sha256 https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 anthropic-apt \
  "claude-desktop_${version}_amd64.deb")"

check_sum "claude-desktop $version" "$want"
