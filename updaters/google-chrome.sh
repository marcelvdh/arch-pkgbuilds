#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
set -euo pipefail

ver="$(bash "$(dirname "$0")/../scripts/apt-latest.sh" https://dl.google.com/linux/chrome/deb stable google-chrome-stable strip)"
[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
sed -i -E "s/^pkgver=.*/pkgver=$ver/" PKGBUILD
echo "$ver"
