#!/usr/bin/env bash
# Shared tail of the updaters: validate a version, write it into ./PKGBUILD
# (resetting pkgrel on a real bump), and print it.
# Run with cwd = the package's folder. Usage: set-pkgver.sh <version>
set -euo pipefail

ver="$1"
[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
cur="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
if [ "$ver" != "$cur" ]; then
  # Never go backwards: stale or replayed upstream metadata would otherwise
  # rewrite pkgver to an older release, which pacman then sees as a downgrade.
  [ "$(printf '%s\n%s\n' "$cur" "$ver" | sort -V | tail -1)" = "$ver" ] \
    || { echo "refusing to move pkgver backwards: $cur -> $ver" >&2; exit 1; }
  sed -i -E "s/^pkgver=.*/pkgver=$ver/; s/^pkgrel=.*/pkgrel=1/" PKGBUILD
fi
echo "$ver"
