#!/usr/bin/env bash
# Check winbox's pinned sha256 against MikroTik's .sha256 sidecar.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
want="$(curl -fsSL -A 'Mozilla/5.0' "https://download.mikrotik.com/routeros/winbox/$version/WinBox_Linux.zip.sha256" \
  | awk '{print $1}')"

check_sum "winbox $version" "$want"
