#!/usr/bin/env bash
# Bump winbox to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(curl -fsSL -A 'Mozilla/5.0' https://mikrotik.com/download/winbox \
  | grep -oE 'download\.mikrotik\.com/routeros/winbox/[0-9.]+/WinBox_Linux\.zip' \
  | cut -d/ -f4 | sort -V | tail -1)"

set_pkgver "$version"
