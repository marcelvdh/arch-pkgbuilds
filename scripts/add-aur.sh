#!/usr/bin/env bash
# Vendor an AUR package's files into packages/<name>/.
# You own the copy afterwards — review the PKGBUILD before trusting it.
# Usage: scripts/add-aur.sh <aur-package-name>
set -euo pipefail

name="$1"
dst="packages/$name"
[ -e "$dst" ] && { echo "$dst already exists" >&2; exit 1; }

git clone --depth 1 "https://aur.archlinux.org/$name.git" "$dst"
rm -rf "$dst/.git" "$dst/.SRCINFO"

echo "Vendored $dst — review the PKGBUILD, and add updaters/$name.sh if you want nightly updates."
