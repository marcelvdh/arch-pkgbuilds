#!/usr/bin/env bash
# Bump google-chrome to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(apt_latest https://dl.google.com/linux/chrome/deb stable amd64 google-linux google-chrome-stable)"

set_pkgver "$version"
