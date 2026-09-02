#!/usr/bin/env bash
# Print the packages with no release for their current pkgver, as a JSON array.
set -euo pipefail

for dir in packages/*/; do
  pkg="$(basename "$dir")"
  ver="$(grep -oPm1 '^pkgver=\K.*' "$dir/PKGBUILD")"
  gh release view "$pkg/v$ver" >/dev/null 2>&1 || echo "$pkg"
done | jq -Rnc '[inputs]'
