#!/usr/bin/env bash
# Run with cwd = the package's folder. Bumps PKGBUILD to the latest version, prints it.
# Anthropic serves the current version as a bare string; the AUR package tracks the
# same endpoint. Use .../claude-code-releases/stable instead to trail the rollout.
set -euo pipefail

ver="$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest | tr -d '[:space:]')"
exec bash "$(dirname "$0")/../scripts/set-pkgver.sh" "$ver"
