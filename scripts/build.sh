#!/usr/bin/env bash
# Lint and build the package in the current directory.
set -euo pipefail

namcap PKGBUILD || true
makepkg -df --noconfirm
namcap ./*.pkg.tar.zst || true
