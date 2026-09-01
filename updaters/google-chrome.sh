#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
set -euo pipefail

dir="$(dirname "$0")"
ver="$(bash "$dir/../scripts/apt-latest.sh" \
  https://dl.google.com/linux/chrome/deb stable amd64 \
  "$dir/../keys/google-linux.asc" google-chrome-stable strip)"
exec bash "$dir/../scripts/set-pkgver.sh" "$ver"
