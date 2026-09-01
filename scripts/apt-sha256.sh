#!/usr/bin/env bash
# Print the SHA256 a signed apt repository publishes for a .deb, or nothing if
# the repository no longer carries that file — an apt index only lists the
# current version, so a superseded one is absent rather than wrong. Real
# failures (bad signature, unreachable repo) exit non-zero.
# Usage: apt-sha256.sh <base-url> <suite> <arch> <keyfile> <deb-filename>
set -euo pipefail

base="$1"; suite="$2"; arch="$3"; keyfile="$4"; deb="$5"

bash "$(dirname "$0")/apt-index.sh" "$base" "$suite" "$arch" "$keyfile" \
  | awk -v f="$deb" '$1 == "Filename:" && substr($2, length($2) - length(f)) == "/" f {m=1}
                     m && $1 == "SHA256:" {print $2; exit}'
