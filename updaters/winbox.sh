#!/usr/bin/env bash
# Bump winbox's PKGBUILD to the latest version, print it.
set -euo pipefail

ver="$(curl -fsSL -A 'Mozilla/5.0' https://mikrotik.com/download/winbox \
  | grep -oE 'download\.mikrotik\.com/routeros/winbox/[0-9.]+/WinBox_Linux\.zip' \
  | cut -d/ -f4 | sort -V | tail -1)"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
