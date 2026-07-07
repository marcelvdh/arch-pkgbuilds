#!/usr/bin/env bash
set -euo pipefail

# SRCINFO_CHECK=0 lets the update flow regenerate .SRCINFO instead of gating on it.
makepkg --printsrcinfo > .SRCINFO.new
if [[ "${SRCINFO_CHECK:-1}" == "1" && -f .SRCINFO ]] && ! diff -u .SRCINFO .SRCINFO.new; then
  echo ".SRCINFO out of sync; run: makepkg --printsrcinfo > .SRCINFO" >&2
  exit 1
fi
mv .SRCINFO.new .SRCINFO

namcap PKGBUILD || true
makepkg -df --noconfirm
namcap ./*.pkg.tar.zst || true
