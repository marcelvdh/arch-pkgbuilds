#!/usr/bin/env bash
# Bump docker-sbx to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

latest="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/docker/sbx-releases/releases/latest)"

set_pkgver "${latest##*/v}"
