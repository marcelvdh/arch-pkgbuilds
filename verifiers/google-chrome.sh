#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's .deb
# checksums (both arches) against Google's apt metadata, signed by the key
# pinned in keys/.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
for arch in amd64 arm64; do
  want="$(bash "$dir/../scripts/apt-sha256.sh" \
    https://dl.google.com/linux/chrome/deb stable "$arch" \
    "$dir/../keys/google-linux.asc" \
    "google-chrome-stable_${ver}-1_${arch}.deb")"
  bash "$dir/../scripts/check-sum.sh" "google-chrome $ver ($arch)" "$want"
done
