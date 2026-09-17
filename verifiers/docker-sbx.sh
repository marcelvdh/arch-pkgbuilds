#!/usr/bin/env bash
# Check docker-sbx's pinned sha256 against Docker's provenance statement.
set -euo pipefail
source "${BASH_SOURCE[0]%/*}/../scripts/lib.sh"

version="$(pkgbuild pkgver)"
want="$(curl -fsSL "https://github.com/docker/sbx-releases/releases/download/v$version/DockerSandboxes-linux-amd64.provenance.json" \
  | jq -r '.subject[0].digest.sha256')"

check_sum "docker-sbx $version" "$want"
