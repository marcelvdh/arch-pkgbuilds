#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# The releases/latest redirect ends in the version tag; no API rate limits.
set -euo pipefail

ver="$(curl -fsSIL -o /dev/null -w '%{url_effective}' https://github.com/docker/sbx-releases/releases/latest | sed -E 's|.*/v||')"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
