#!/usr/bin/env bash
# Cross-check claude-code's PKGBUILD sums against Anthropic's release manifest.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
manifest="$(curl -fsSL "https://downloads.claude.ai/claude-code-releases/$ver/manifest.json")"
for platform in linux-x64 linux-arm64; do
  want="$(jq -r --arg p "$platform" '.platforms[$p].checksum' <<<"$manifest")"
  bash "$dir/../scripts/check-sum.sh" "claude-code $ver ($platform)" "$want"
done
