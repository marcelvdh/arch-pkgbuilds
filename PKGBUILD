# Maintainer: marcelvdh <marcelvdh@linux.com>

pkgname=claude-desktop-official
pkgver=1.19367.0
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
sha512sums=('e4ed7c51f6f8d9d182df26d1e5edeaa9f66819650d603d648312afd5b6da013e24bd8e686fb9734d9060f7e69c8f30e79c63cdf1cb80b7813895ac221097e283')

package() {
	bsdtar -xf "$srcdir/claude-desktop_${pkgver}_amd64.deb" -C "$srcdir"

	bsdtar -xf "$srcdir"/data.tar.* -C "$pkgdir/"

	install -Dm644 "$pkgdir/usr/share/doc/claude-desktop/copyright" \
		"$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
