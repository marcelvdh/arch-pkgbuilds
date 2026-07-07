#!/usr/bin/env bash
set -euo pipefail

version="$1"
sed -i -E "s/^pkgver=.*/pkgver=$version/" PKGBUILD
sed -i -E "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
updpkgsums
SRCINFO_CHECK=0 bash scripts/build.sh
