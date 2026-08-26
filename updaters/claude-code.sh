#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# Anthropic serves the current version as a bare string; the AUR package tracks the
# same endpoint. Use .../claude-code-releases/stable instead to trail the rollout.
set -euo pipefail

ver="$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest | tr -d '[:space:]')"

[[ "$ver" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || { echo "suspicious version: $ver" >&2; exit 1; }
sed -i -E "s/^pkgver=.*/pkgver=$ver/" PKGBUILD
echo "$ver"
