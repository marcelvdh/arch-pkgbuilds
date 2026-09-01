#!/usr/bin/env bash
# Cross-check docker-sbx's PKGBUILD sum against the digest in Docker's provenance statement.
set -euo pipefail

ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
want="$(curl -fsSL "https://github.com/docker/sbx-releases/releases/download/v$ver/DockerSandboxes-linux-amd64.provenance.json" \
  | jq -r '.subject[0].digest.sha256')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "docker-sbx $ver" "$want"
