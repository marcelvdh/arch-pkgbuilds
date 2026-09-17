#!/usr/bin/env bash
# Check claude-code's pinned sha256 against Anthropic's release manifest.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
manifest="$(curl -fsSL "https://downloads.claude.ai/claude-code-releases/$version/manifest.json")"

for platform in linux-x64 linux-arm64; do
  want="$(jq -r --arg p "$platform" '.platforms[$p].checksum' <<<"$manifest")"
  check_sum "claude-code $version ($platform)" "$want"
done
