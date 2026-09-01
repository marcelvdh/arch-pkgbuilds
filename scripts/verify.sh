#!/usr/bin/env bash
# Run the package's verifier if it has one; a missing one warns, never fails silently.
set -euo pipefail

pkg="$(basename "$PWD")"
verifier="$(dirname "$0")/../verifiers/$pkg.sh"
[ -f "$verifier" ] || { echo "::warning::no verifier for $pkg"; exit 0; }
exec bash "$verifier"
