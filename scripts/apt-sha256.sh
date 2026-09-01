#!/usr/bin/env bash
# Print the SHA256 a signed apt repository publishes for a .deb, or nothing if it no longer carries it.
set -euo pipefail

base="$1"; suite="$2"; arch="$3"; keyfile="$4"; deb="$5"

bash "$(dirname "$0")/apt-index.sh" "$base" "$suite" "$arch" "$keyfile" \
  | awk -v f="$deb" '$1 == "Filename:" && substr($2, length($2) - length(f)) == "/" f {m=1}
                     m && $1 == "SHA256:" {print $2; exit}'
