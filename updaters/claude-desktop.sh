#!/usr/bin/env bash
# Bump claude-desktop to the latest upstream version.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(apt_latest https://downloads.claude.ai/claude-desktop/apt/stable stable amd64 anthropic-apt claude-desktop)"

set_pkgver "$version"
