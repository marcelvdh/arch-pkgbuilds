#!/usr/bin/env bash
# Check jetbrains-toolbox's pinned sha256 against JetBrains' .sha256 sidecar.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
want="$(curl -fsSL "https://download.jetbrains.com/toolbox/jetbrains-toolbox-$version.tar.gz.sha256" \
  | awk '{print $1}')"

check_sum "jetbrains-toolbox $version" "$want"
