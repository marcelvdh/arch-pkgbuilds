#!/usr/bin/env bash
# Bump herdr-bin to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

latest="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/herdrdev/herdr/releases/latest)"

set_pkgver "${latest##*/v}"
