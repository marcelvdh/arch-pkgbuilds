#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's tarball
# checksum against the checksums.txt Docker publishes per build revision. That
# file is unsigned and served from the same host as the tarball, so this
# catches a bad download, not a compromised publisher.
set -euo pipefail

rev="$(grep -oPm1 '^_revision=\K.*' PKGBUILD)"
want="$(curl -fsSL "https://desktop.docker.com/linux/main/amd64/$rev/checksums.txt" \
  | awk '$2=="*docker-desktop-x86_64.pkg.tar.zst"{print $1}')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "docker-desktop rev $rev" "$want"
