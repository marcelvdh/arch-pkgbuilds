#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
set -euo pipefail

ver="$(bash "$(dirname "$0")/../scripts/apt-latest.sh" https://dl.google.com/linux/chrome/deb stable google-chrome-stable strip)"
sed -i -E "s/^pkgver=.*/pkgver=$ver/" PKGBUILD
echo "$ver"
