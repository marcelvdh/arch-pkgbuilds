#!/usr/bin/env bash
# Shared tail of the verifiers: assert that a checksum upstream publishes is
# pinned in ./PKGBUILD. An empty checksum means upstream no longer carries this
# version, which is not a failure — a lookup that actually failed exits
# non-zero before reaching here.
# Run with cwd = the package's folder. Usage: check-sum.sh <label> <sha256>
set -euo pipefail

label="$1"; want="$2"

if [ -z "$want" ]; then
  echo "$label: upstream no longer publishes a checksum for this version"
  exit 0
fi
[[ "$want" =~ ^[0-9a-f]{64}$ ]] \
  || { echo "$label: upstream returned a malformed sha256 '$want'" >&2; exit 1; }
grep -qF "$want" PKGBUILD \
  || { echo "$label: upstream sha256 '$want' not in PKGBUILD" >&2; exit 1; }
echo "$label: PKGBUILD pins the upstream-published sha256"
