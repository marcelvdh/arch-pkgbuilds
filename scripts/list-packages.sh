#!/usr/bin/env bash
# Print every package name under packages/ as a JSON array.
set -euo pipefail

ls packages | jq -Rnc '[inputs]'
