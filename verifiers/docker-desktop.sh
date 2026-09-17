#!/usr/bin/env bash
# Check docker-desktop's pinned sha256 against Docker's per-revision checksums.txt.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

revision="$(pkgbuild _revision)"
want="$(curl -fsSL "https://desktop.docker.com/linux/main/amd64/$revision/checksums.txt" \
  | awk '$2 == "*docker-desktop-x86_64.pkg.tar.zst" {print $1}')"

check_sum "docker-desktop rev $revision" "$want"
