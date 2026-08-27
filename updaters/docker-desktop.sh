#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# Docker's appcast gives both the version and the build revision the URL needs.
set -euo pipefail

read -r ver rev < <(curl -fsSL https://desktop.docker.com/linux/main/amd64/appcast.xml \
  | grep -oE 'Version [0-9.]+ \([0-9]+\)' \
  | sed -E 's/Version ([0-9.]+) \(([0-9]+)\)/\1 \2/' \
  | sort -V | tail -1)

[[ "$rev" =~ ^[0-9]+$ ]] || { echo "suspicious revision: $rev" >&2; exit 1; }
sed -i -E "s/^_revision=.*/_revision=$rev/" PKGBUILD
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
