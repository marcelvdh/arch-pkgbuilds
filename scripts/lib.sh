#!/usr/bin/env bash
# Shared helpers for the updaters, verifiers and workflows.

repo_root="$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd)"

die() {
  echo "$*" >&2
  exit 1
}

pkgbuild() {
  grep -oPm1 "^$1=\K.*" "${2:-PKGBUILD}"
}

set_pkgver() {
  local new="$1" current newest
  [[ "$new" =~ ^[0-9][0-9A-Za-z._-]*$ ]] || die "suspicious version: $new"

  current="$(pkgbuild pkgver)"
  if [ "$new" != "$current" ]; then
    newest="$(printf '%s\n%s\n' "$current" "$new" | sort -V | tail -1)"
    [ "$newest" = "$new" ] || die "refusing to move pkgver backwards: $current -> $new"
    sed -i -E "s/^pkgver=.*/pkgver=$new/; s/^pkgrel=.*/pkgrel=1/" PKGBUILD
  fi
  echo "$new"
}

check_sum() {
  local label="$1" want="$2"
  if [ -z "$want" ]; then
    echo "$label: upstream no longer publishes a checksum for this version"
    return 0
  fi
  [[ "$want" =~ ^[0-9a-f]{64}$ ]] || die "$label: upstream returned a malformed sha256 '$want'"
  grep -qF "$want" PKGBUILD || die "$label: upstream sha256 '$want' not in PKGBUILD"
  echo "$label: PKGBUILD pins the upstream-published sha256"
}

clearsigned_body() {
  awk '/^-----BEGIN PGP SIGNED MESSAGE-----$/ {in_armor = 1; next}
       in_armor && !in_body && /^$/ {in_body = 1; next}
       /^-----BEGIN PGP SIGNATURE-----$/ {exit}
       in_body' "$1"
}

apt_index() (
  local base="$1" suite="$2" arch="$3" key="$4"
  local tmp index published actual
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  curl -fsSL "$base/dists/$suite/InRelease" -o "$tmp/InRelease"
  gpg --dearmor < "$repo_root/keys/$key.asc" > "$tmp/keyring.gpg"
  gpgv --keyring "$tmp/keyring.gpg" "$tmp/InRelease"
  clearsigned_body "$tmp/InRelease" > "$tmp/Release"

  index="main/binary-$arch/Packages"
  curl -fsSL "$base/dists/$suite/$index" -o "$tmp/Packages"
  published="$(awk -v want="$index" '/^SHA256:/ {in_sums = 1; next}
                                     /^[A-Z]/ {in_sums = 0}
                                     in_sums && $3 == want {print $1; exit}' "$tmp/Release")"
  actual="$(sha256sum "$tmp/Packages" | cut -d' ' -f1)"
  [ -n "$published" ] && [ "$published" = "$actual" ] \
    || die "$base $suite/$arch: Packages index does not match the signed InRelease"

  cat "$tmp/Packages"
)

apt_latest() {
  local base="$1" suite="$2" arch="$3" key="$4" pkg="$5" version
  version="$(apt_index "$base" "$suite" "$arch" "$key" \
    | awk -v want="$pkg" '$1 == "Package:" {wanted = ($2 == want)}
                          wanted && $1 == "Version:" {print $2}' \
    | sort -V | tail -1)"
  [ -n "$version" ] || die "$pkg is not in $base $suite/$arch"

  local without_debian_revision="${version%-*}"
  echo "$without_debian_revision"
}

apt_sha256() {
  local base="$1" suite="$2" arch="$3" key="$4" deb="$5"
  apt_index "$base" "$suite" "$arch" "$key" \
    | awk -v want="$deb" '$1 == "Filename:" && substr($2, length($2) - length(want)) == "/" want {found = 1}
                          found && $1 == "SHA256:" {print $2; exit}'
}
