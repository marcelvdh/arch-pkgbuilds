#!/usr/bin/env bash
set -euo pipefail

version="$1"
rel="${2:-1}"
sed -i -E "s/^pkgver=.*/pkgver=$version/" PKGBUILD
sed -i -E "s/^pkgrel=.*/pkgrel=$rel/" PKGBUILD
updpkgsums
SRCINFO_CHECK=0 bash scripts/build.sh
