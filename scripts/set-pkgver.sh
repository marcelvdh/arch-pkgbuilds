#!/usr/bin/env bash
# Shared tail of the updaters: validate a version, write it into ./PKGBUILD
# (resetting pkgrel on a real bump), and print it.
# Run with cwd = the package's folder. Usage: set-pkgver.sh <version>
set -euo pipefail

ver="$1"
[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
if [ "$ver" != "$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)" ]; then
  sed -i -E "s/^pkgver=.*/pkgver=$ver/; s/^pkgrel=.*/pkgrel=1/" PKGBUILD
fi
echo "$ver"
