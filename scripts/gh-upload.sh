#!/usr/bin/env bash
set -euo pipefail

tag="$1"; shift
attempts="${GH_UPLOAD_ATTEMPTS:-5}"
parallel="${GH_UPLOAD_JOBS:-4}"

upload_one() {
  local f="$1" per_try n
  per_try="${GH_UPLOAD_TIMEOUT:-$(( $(stat -c%s -- "$f") / 8388608 + 45 ))s}"
  for n in $(seq 1 "$attempts"); do
    if timeout -k 30s "$per_try" gh release upload "$tag" "$f" --clobber; then
      return 0
    fi
    echo "::warning::$(basename "$f") -> $tag stalled or failed within $per_try (attempt $n/$attempts)"
    sleep $((n * 10))   # the endpoint is failing server-side; give it room
  done
  echo "::error::$(basename "$f") -> $tag failed after $attempts attempts"
  return 1
}

failed=0
running=0
for f in "$@"; do
  upload_one "$f" &
  running=$((running + 1))
  if [ "$running" -ge "$parallel" ]; then
    wait -n || failed=1
    running=$((running - 1))
  fi
done
while [ "$running" -gt 0 ]; do
  wait -n || failed=1
  running=$((running - 1))
done

exit "$failed"
