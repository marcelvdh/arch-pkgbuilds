#!/usr/bin/env bash
# Check google-chrome's pinned sha256 against Google's signed apt metadata.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"

for arch in amd64 arm64; do
  want="$(apt_sha256 https://dl.google.com/linux/chrome/deb stable "$arch" google-linux \
    "google-chrome-stable_${version}-1_${arch}.deb")"

  # An apt index lists only the current version, so a missing entry means this
  # release was superseded, not that the check failed.
  [ -n "$want" ] || { echo "google-chrome $version ($arch): superseded, no longer in the apt index"; continue; }

  check_sum "google-chrome $version ($arch)" "$want"
done
