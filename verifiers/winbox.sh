#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's zip checksum
# against the .sha256 sidecar MikroTik publishes next to it. The sidecar is
# unsigned and served from the same host as the zip, so this catches a bad
# download, not a compromised publisher.
set -euo pipefail

ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
want="$(curl -fsSL -A 'Mozilla/5.0' "https://download.mikrotik.com/routeros/winbox/$ver/WinBox_Linux.zip.sha256" \
  | awk '{print $1}')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "winbox $ver" "$want"
