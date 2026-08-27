#!/usr/bin/env bash
# Print the names of all packages under packages/ as a JSON array.
# Run from the repository root.
set -euo pipefail

find packages -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
  | jq -Rsc 'split("\n")|map(select(length>0))'
