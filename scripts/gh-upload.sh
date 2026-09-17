#!/usr/bin/env bash
# Upload release assets, retrying when an upload stalls.
#
# gh's HTTP client has no timeout, so a connection to uploads.github.com that
# goes quiet mid-transfer hangs the job until the 6h limit instead of failing.
# `timeout` turns that stall into a retry; --clobber makes each retry idempotent.
set -euo pipefail

tag="$1"; shift
[ "$#" -gt 0 ] || exit 0

attempts="${GH_UPLOAD_ATTEMPTS:-4}"
per_try="${GH_UPLOAD_TIMEOUT:-8m}"

for n in $(seq 1 "$attempts"); do
  if timeout -k 30s "$per_try" gh release upload "$tag" "$@" --clobber; then
    exit 0
  fi
  echo "::warning::upload to $tag stalled or failed (attempt $n/$attempts)"
  sleep $((n * 30))   # the endpoint is failing server-side; give it room
done

echo "::error::upload to $tag failed after $attempts attempts"
exit 1
