#!/usr/bin/env bash
# Run with cwd = the package's folder. Cross-checks the PKGBUILD's tarball
# checksum against the subject digest in the provenance Docker attaches to the
# release. Only the statement is read, not its signature, so this is a
# same-origin cross-check — `gh attestation verify` would be the real thing.
set -euo pipefail

ver="$(grep -oPm1 '^pkgver=\K.*' PKGBUILD)"
want="$(curl -fsSL "https://github.com/docker/sbx-releases/releases/download/v$ver/DockerSandboxes-linux-amd64.provenance.json" \
  | jq -r '.subject[0].digest.sha256')"
exec bash "$(dirname "$0")/../scripts/check-sum.sh" "docker-sbx $ver" "$want"
