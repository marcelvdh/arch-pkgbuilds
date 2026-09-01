#!/usr/bin/env bash
# Vendor packages/<name>/ from the AUR.
set -euo pipefail

name="$1"
dst="packages/$name"
[ -e "$dst" ] && { echo "$dst already exists" >&2; exit 1; }

git clone --depth 1 "https://aur.archlinux.org/$name.git" "$dst"
rm -rf "$dst/.git" "$dst/.SRCINFO"

echo "Vendored $dst — review the PKGBUILD, and add updaters/$name.sh if you want nightly updates."
