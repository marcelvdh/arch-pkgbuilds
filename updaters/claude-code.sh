#!/usr/bin/env bash
# Bump claude-code to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(curl -fsSL https://downloads.claude.ai/claude-code-releases/latest | tr -d '[:space:]')"

set_pkgver "$version"
