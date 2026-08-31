#!/usr/bin/env bash
# Shared tail of the verifiers: assert that a checksum upstream publishes
# is pinned in ./PKGBUILD.
# Run with cwd = the package's folder. Usage: check-sum.sh <label> <sha256>
set -euo pipefail

label="$1"; want="$2"
[[ "$want" =~ ^[0-9a-f]{64}$ ]] && grep -qF "$want" PKGBUILD \
  || { echo "$label: upstream sha256 '$want' not in PKGBUILD" >&2; exit 1; }
echo "$label: PKGBUILD pins the upstream-published sha256"
