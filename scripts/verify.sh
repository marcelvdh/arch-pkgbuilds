#!/usr/bin/env bash
# Run the current package's verifier, if it has one.
set -euo pipefail

pkg="$(basename "$PWD")"
verifier="${BASH_SOURCE[0]%/*}/../verifiers/$pkg.sh"

[ -f "$verifier" ] || { echo "::warning::no verifier for $pkg"; exit 0; }
exec bash "$verifier"
