#!/usr/bin/env bash
# Upload release assets, retrying each one independently.
set -euo pipefail

tag="$1"; shift
attempts="${GH_UPLOAD_ATTEMPTS:-5}"
parallel="${GH_UPLOAD_JOBS:-4}"

upload() {
  local file="$1" budget attempt
  budget="${GH_UPLOAD_TIMEOUT:-$(( $(stat -c%s -- "$file") / 8388608 + 45 ))s}"

  for attempt in $(seq 1 "$attempts"); do
    timeout -k 30s "$budget" gh release upload "$tag" "$file" --clobber && return 0
    echo "::warning::$(basename "$file") -> $tag failed within $budget (attempt $attempt/$attempts)"
    sleep $((attempt * 10))
  done

  echo "::error::$(basename "$file") -> $tag failed after $attempts attempts"
  return 1
}

failed=0
running=0
reap() { wait -n || failed=1; running=$((running - 1)); }

for file in "$@"; do
  upload "$file" &
  running=$((running + 1))
  if [ "$running" -ge "$parallel" ]; then reap; fi
done
while [ "$running" -gt 0 ]; do reap; done

exit "$failed"
