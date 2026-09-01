#!/usr/bin/env bash
# Bump claude-code's PKGBUILD to the latest version, print it.
set -euo pipefail

ver="$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest | tr -d '[:space:]')"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
