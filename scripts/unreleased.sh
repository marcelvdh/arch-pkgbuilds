#!/usr/bin/env bash
# Print the packages with no release for their current pkgver, as a JSON array.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/lib.sh"

for dir in packages/*/; do
  pkg="$(basename "$dir")"
  gh release view "$pkg/v$(pkgbuild pkgver "$dir/PKGBUILD")" >/dev/null 2>&1 || echo "$pkg"
done | jq -Rnc '[inputs]'
