#!/usr/bin/env bash
# Print the SHA256 an apt repository publishes for a .deb, after verifying
# the InRelease signature against a pinned key and the Packages index
# against the signed InRelease.
# Usage: apt-sha256.sh <base-url> <suite> <arch> <keyfile> <deb-filename>
set -euo pipefail

base="$1"; suite="$2"; arch="$3"; keyfile="$4"; deb="$5"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$base/dists/$suite/InRelease" -o "$tmp/InRelease"
gpg --dearmor < "$keyfile" > "$tmp/keyring.gpg"
gpgv --keyring "$tmp/keyring.gpg" "$tmp/InRelease"
# the clearsigned body: after the armor header block, before the signature
awk '/^-----BEGIN PGP SIGNED MESSAGE-----$/{f=1;next} f&&!b&&/^$/{b=1;next} /^-----BEGIN PGP SIGNATURE-----$/{exit} b' \
  "$tmp/InRelease" > "$tmp/Release"

path="main/binary-$arch/Packages"
curl -fsSL "$base/dists/$suite/$path" -o "$tmp/Packages"
want="$(awk -v p="$path" '/^SHA256:/{s=1;next} /^[A-Z]/{s=0} s&&$3==p{print $1}' "$tmp/Release")"
have="$(sha256sum "$tmp/Packages" | cut -d' ' -f1)"
[ "$want" = "$have" ] \
  || { echo "Packages index does not match the signed InRelease" >&2; exit 1; }

awk -v f="$deb" '$1=="Filename:" && $2 ~ ("/" f "$") {m=1} m && $1=="SHA256:" {print $2; exit}' "$tmp/Packages"
