#!/usr/bin/env bash
set -euo pipefail

namcap PKGBUILD || true
makepkg -df --noconfirm
namcap ./*.pkg.tar.zst || true
