#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# The releases/latest redirect ends in the version tag; no API rate limits.
set -euo pipefail

ver="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/docker/sbx-releases/releases/latest | sed -E 's|.*/v||')"

[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
sed -i -E "s/^pkgver=.*/pkgver=$ver/" PKGBUILD
echo "$ver"
