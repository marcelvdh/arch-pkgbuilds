#!/usr/bin/env bash
# Run the package's verifier, if it has one. Verifiers are optional, so a
# missing one is a warning rather than a failure — but never a silent skip.
# Run with cwd = the package's folder. Usage: verify.sh
set -euo pipefail

pkg="$(basename "$PWD")"
verifier="$(dirname "$0")/../verifiers/$pkg.sh"
[ -f "$verifier" ] || { echo "::warning::no verifier for $pkg"; exit 0; }
exec bash "$verifier"
