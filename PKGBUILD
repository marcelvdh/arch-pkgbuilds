# Maintainer: marcelvdh <marcelvdh@linux.com>

pkgname=claude-desktop-official
pkgver=1.18286.2
pkgrel=1
pkgdesc="Claude Desktop Client (Stable Release Channel)"
arch=('x86_64')
url="https://claude.com/download"
license=('LicenseRef-proprietary')

depends=(
  'alsa-lib'
  'at-spi2-core'
  'cairo'
  'dbus'
  'expat'
  'glib2'
  'glibc'
  'gtk3'
  'hicolor-icon-theme'
  'libcap-ng'
  'libcups'
  'libseccomp'
  'libx11'
  'libxcb'
  'libxcomposite'
  'libxdamage'
  'libxext'
  'libxfixes'
  'libxkbcommon'
  'libxrandr'
  'mesa'
  'nspr'
  'nss'
  'pango'
)

optdepends=(
  'nodejs: Core runtime layer to execute JavaScript/TypeScript MCP extensions'
  'python: Layer to execute Python-based MCP extension servers'
  'qemu-desktop: Required for Cowork/Computer Use sandboxed microVM isolation'
  'virtiofsd: Provides host-to-guest shared folder mounting paths under QEMU isolation'
)

options=('!emptydirs' '!strip')
_channel=stable

source=("https://downloads.claude.ai/claude-desktop/apt/${_channel}/pool/main/c/claude-desktop/claude-desktop_${pkgver}_amd64.deb")
sha512sums=('808be6ce84a3eb06525fab3ee9eb8c46484c1e283e6d688c60b63243c692a1b3af494dc023ac88a20d9d57f5282f8f867980d0ad2cb6c0a0bcd5c7fc300f512e')

package() {
	bsdtar -xf "$srcdir/claude-desktop_${pkgver}_amd64.deb" -C "$srcdir"

	bsdtar -xf "$srcdir"/data.tar.* -C "$pkgdir/"

	install -Dm644 "$pkgdir/usr/share/doc/claude-desktop/copyright" \
		"$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
