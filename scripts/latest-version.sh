#!/usr/bin/env bash
#
# Print the latest upstream claude-desktop version from Anthropic's APT repo.
#
# The APT repo publishes a machine-readable Packages index listing every
# available Version:, SHA256: and Filename:. We take the highest version
# (Debian/`sort -V` ordering, which matches Arch's expectations for these
# dotted-numeric versions).
#
# Usage:
#   scripts/latest-version.sh            # print latest version, e.g. 1.18286.2
#   scripts/latest-version.sh --deb      # print the matching .deb filename
#
# Pure curl/awk/sort so it also runs on macOS for local testing.
set -euo pipefail

CHANNEL="${CLAUDE_CHANNEL:-stable}"
ARCH="${CLAUDE_ARCH:-amd64}"
BASE="https://downloads.claude.ai/claude-desktop/apt/${CHANNEL}"
PACKAGES_URL="${BASE}/dists/${CHANNEL}/main/binary-${ARCH}/Packages"

packages="$(curl -fsSL "$PACKAGES_URL")"

latest="$(printf '%s\n' "$packages" | awk '/^Version:/{print $2}' | sort -V | tail -1)"

if [[ -z "$latest" ]]; then
  echo "error: could not determine latest version from $PACKAGES_URL" >&2
  exit 1
fi

if [[ "${1:-}" == "--deb" ]]; then
  # Print the Filename: of the stanza matching the latest version.
  printf '%s\n' "$packages" \
    | awk -v v="$latest" 'BEGIN{RS="";FS="\n"} $0 ~ ("(^|\n)Version: " v "($|\n)") {
        for (i=1;i<=NF;i++) if ($i ~ /^Filename:/) { sub(/^Filename:[ \t]*/,"",$i); print $i }
      }'
  exit 0
fi

printf '%s\n' "$latest"
