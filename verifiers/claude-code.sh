#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's binary
# checksums (both arches) against Anthropic's release manifest.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
manifest="$(curl -fsSL "https://downloads.claude.ai/claude-code-releases/$ver/manifest.json")"
for platform in linux-x64 linux-arm64; do
  bash "$dir/../scripts/check-sum.sh" "claude-code $ver ($platform)" \
    "$(jq -r --arg p "$platform" '.platforms[$p].checksum' <<<"$manifest")"
done
