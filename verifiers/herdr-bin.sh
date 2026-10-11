#!/usr/bin/env bash
# Check herdr-bin's pinned sha256s against the assets GitHub's signed release
# attestation lists for the tag. gh needs GH_TOKEN even for a public repository.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for arch in x86_64 aarch64; do
  asset="herdr-linux-$arch"
  curl -fsSL "https://github.com/herdrdev/herdr/releases/download/v$version/$asset" -o "$tmp/$asset"
  gh release verify-asset "v$version" "$tmp/$asset" --repo herdrdev/herdr
  check_sum "herdr-bin $version $arch" "$(sha256sum "$tmp/$asset" | cut -d' ' -f1)"
done
