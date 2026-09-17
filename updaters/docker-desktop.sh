#!/usr/bin/env bash
# Bump docker-desktop to the latest upstream version and revision.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

read -r version revision < <(curl -fsSL https://desktop.docker.com/linux/main/amd64/appcast.xml \
  | grep -oE 'Version [0-9.]+ \([0-9]+\)' \
  | sed -E 's/Version ([0-9.]+) \(([0-9]+)\)/\1 \2/' \
  | sort -V | tail -1)

[[ "$revision" =~ ^[0-9]+$ ]] || die "suspicious revision: $revision"
sed -i -E "s/^_revision=.*/_revision=$revision/" PKGBUILD

set_pkgver "$version"
