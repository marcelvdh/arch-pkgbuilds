#!/usr/bin/env bash
# Fail unless the diff against $1 is a plain version bump: one PKGBUILD, and only
# pkgver/pkgrel/_revision/sha256sums lines. This is what a reviewer would check
# on an autoupdate PR, so bot PRs may merge without one. CI runs the base
# branch's copy, so it must stand alone: a PR cannot vouch for itself.
set -euo pipefail

die() {
  echo "$*" >&2
  exit 1
}

base="$1"
changed="$(git diff --name-only "$base"...HEAD)"
[ "$(wc -l <<<"$changed")" = 1 ] && [[ "$changed" == packages/*/PKGBUILD ]] \
  || die "a bot PR may only change one PKGBUILD, got:"$'\n'"$changed"

allowed='^[-+](pkgver|_revision)=[0-9][0-9A-Za-z._-]*$'
allowed+='|^[-+]pkgrel=[0-9]+$'
allowed+="|^[-+]sha256sums(_[a-z0-9_]+)?=\(('[0-9a-f]{64}')?\)?$"
allowed+="|^[-+] *'[0-9a-f]{64}'\)?$"
bad="$(git diff -U0 "$base"...HEAD -- "$changed" | grep -E '^[-+]' | grep -vE '^(\+\+\+|---) ' | grep -vE "$allowed" || true)"
[ -z "$bad" ] || die "a bot PR may only change version and checksum lines, got:"$'\n'"$bad"
echo "$changed: plain version bump"
