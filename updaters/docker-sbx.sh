#!/usr/bin/env bash
# Bump docker-sbx's PKGBUILD to the latest version, print it.
set -euo pipefail

ver="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/docker/sbx-releases/releases/latest | sed -E 's|.*/v||')"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
