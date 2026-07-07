#!/usr/bin/env bash
#
# Validate and build the package. Intended to run as a NON-root user inside an
# archlinux container that already has base-devel + pacman-contrib + namcap
# installed. Shared by the build, update and release workflows so the build
# logic lives in exactly one place.
#
# Produces: ./*.pkg.tar.zst in the current directory.
set -euo pipefail

echo "::group::Regenerate and check .SRCINFO"
makepkg --printsrcinfo > .SRCINFO.new
if [[ -f .SRCINFO ]] && ! diff -u .SRCINFO .SRCINFO.new; then
  echo "::error::.SRCINFO is out of sync with PKGBUILD. Run: makepkg --printsrcinfo > .SRCINFO"
  rm -f .SRCINFO.new
  exit 1
fi
mv .SRCINFO.new .SRCINFO
echo "::endgroup::"

echo "::group::namcap PKGBUILD"
# Informational: namcap warnings are common and shouldn't fail the build.
# Fail only on hard errors (lines beginning with 'E:').
if namcap PKGBUILD | tee /tmp/namcap-pkgbuild.txt; then :; fi
if grep -q '^PKGBUILD E:' /tmp/namcap-pkgbuild.txt; then
  echo "::error::namcap reported errors on PKGBUILD"
  exit 1
fi
echo "::endgroup::"

echo "::group::makepkg"
# -d: skip installing the (many) runtime deps; we only unpack a .deb to build.
# -f: overwrite an existing built package. --noconfirm for non-interactive CI.
makepkg -df --noconfirm
echo "::endgroup::"

echo "::group::namcap built package"
namcap ./*.pkg.tar.zst || true
echo "::endgroup::"

echo "Built package(s):"
ls -1 ./*.pkg.tar.zst
