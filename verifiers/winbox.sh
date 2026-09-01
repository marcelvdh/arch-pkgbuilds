#!/usr/bin/env bash
# Cross-check winbox's PKGBUILD sum against MikroTik's .sha256 sidecar.
set -euo pipefail

ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
want="$(curl -fsSL -A 'Mozilla/5.0' "https://download.mikrotik.com/routeros/winbox/$ver/WinBox_Linux.zip.sha256" \
  | awk '{print $1}')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "winbox $ver" "$want"
