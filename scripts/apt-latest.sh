#!/usr/bin/env bash
# Print the latest version of a package in a signed apt repository.
# Usage: apt-latest.sh <base-url> <suite> <arch> <keyfile> <pkg> [strip-release]
set -euo pipefail

base="$1"; suite="$2"; arch="$3"; keyfile="$4"; pkg="$5"; strip="${6:-}"

ver="$(bash "$(dirname "$0")/apt-index.sh" "$base" "$suite" "$arch" "$keyfile" \
  | awk -v p="$pkg" '$1=="Package:"{m=($2==p)} m&&$1=="Version:"{print $2}' \
  | sort -V | tail -1)"

[ -n "$ver" ] || { echo "$pkg is not in $base $suite/$arch" >&2; exit 1; }
[ -n "$strip" ] && ver="${ver%-*}"   # drop the -N debian release suffix
echo "$ver"
