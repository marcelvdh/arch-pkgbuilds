#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# The WinBox download page links WinBox_Linux.zip with the version in its path.
set -euo pipefail

ver="$(curl -fsSL -A 'Mozilla/5.0' https://mikrotik.com/download/winbox \
  | grep -oE 'download\.mikrotik\.com/routeros/winbox/[0-9.]+/WinBox_Linux\.zip' \
  | cut -d/ -f4 | sort -V | tail -1)"

[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
sed -i -E "s/^pkgver=.*/pkgver=$ver/" PKGBUILD
echo "$ver"
