#!/usr/bin/env bash
# Print a Debian apt repository's Packages index, after verifying the InRelease
# signature against a pinned key and the index against the signed InRelease.
# Usage: apt-index.sh <base-url> <suite> <arch> <keyfile>
set -euo pipefail

base="$1"; suite="$2"; arch="$3"; keyfile="$4"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$base/dists/$suite/InRelease" -o "$tmp/InRelease"
gpg --dearmor < "$keyfile" > "$tmp/keyring.gpg"
gpgv --keyring "$tmp/keyring.gpg" "$tmp/InRelease"
# the clearsigned body: after the armor header block, before the signature
awk '/^-----BEGIN PGP SIGNED MESSAGE-----$/{f=1;next} f&&!b&&/^$/{b=1;next} /^-----BEGIN PGP SIGNATURE-----$/{exit} b' \
  "$tmp/InRelease" > "$tmp/Release"

path="main/binary-$arch/Packages"
curl -fsSL "$base/dists/$suite/$path" -o "$tmp/Packages"
want="$(awk -v p="$path" '/^SHA256:/{s=1;next} /^[A-Z]/{s=0} s&&$3==p{print $1;exit}' "$tmp/Release")"
have="$(sha256sum "$tmp/Packages" | cut -d' ' -f1)"
[ -n "$want" ] && [ "$want" = "$have" ] \
  || { echo "$base $suite/$arch: Packages index does not match the signed InRelease" >&2; exit 1; }

cat "$tmp/Packages"
