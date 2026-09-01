#!/usr/bin/env bash
# Print every package name under packages/ as a JSON array.
set -euo pipefail

find packages -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
  | jq -Rsc 'split("\n")|map(select(length>0))'
