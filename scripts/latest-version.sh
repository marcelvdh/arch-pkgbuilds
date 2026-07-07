#!/usr/bin/env bash
set -euo pipefail

url="https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages"
curl -fsSL "$url" | awk '/^Version:/{print $2}' | sort -V | tail -1
