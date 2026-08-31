#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's tarball
# checksum against the checksums.txt Docker publishes per build revision.
set -euo pipefail

rev="$(grep -oPm1 '^_revision=\K.*' PKGBUILD)"
want="$(curl -fsSL "https://desktop.docker.com/linux/main/amd64/$rev/checksums.txt" \
  | awk '$2=="*docker-desktop-x86_64.pkg.tar.zst"{print $1}')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "docker-desktop rev $rev" "$want"
