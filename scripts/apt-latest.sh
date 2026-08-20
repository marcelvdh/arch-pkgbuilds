#!/usr/bin/env bash
# Print the latest version of a package from a Debian apt repository.
# Usage: apt-latest.sh <base-url> <suite> <pkg> [strip-release]
set -euo pipefail

base="$1"; suite="$2"; pkg="$3"; strip="${4:-}"

ver="$(curl -fsSL "$base/dists/$suite/main/binary-amd64/Packages" \
  | awk -v p="$pkg" '$1=="Package:"{m=($2==p)} m&&$1=="Version:"{print $2}' \
  | sort -V | tail -1)"

[ -n "$strip" ] && ver="${ver%-*}"   # drop the -N debian release suffix
echo "$ver"
