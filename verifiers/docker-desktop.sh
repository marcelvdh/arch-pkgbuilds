#!/usr/bin/env bash
# Cross-check docker-desktop's PKGBUILD sum against Docker's per-revision checksums.txt.
set -euo pipefail

rev="$(grep -oPm1 '^_revision=\K.*' PKGBUILD)"
want="$(curl -fsSL "https://desktop.docker.com/linux/main/amd64/$rev/checksums.txt" \
  | awk '$2=="*docker-desktop-x86_64.pkg.tar.zst"{print $1}')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "docker-desktop rev $rev" "$want"
