#!/usr/bin/env bash
# Bump jetbrains-toolbox to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
  | jq -r '.TBA[0].build')"

set_pkgver "$version"
