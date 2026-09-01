#!/usr/bin/env bash
# Bump google-chrome's PKGBUILD to the latest version, print it.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(bash "$dir/../scripts/apt-latest.sh" \
  https://dl.google.com/linux/chrome/deb stable amd64 \
  "$dir/../keys/google-linux.asc" google-chrome-stable strip)"
exec bash "$dir/../scripts/set-pkgver.sh" "$ver"
