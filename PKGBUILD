# Maintainer: marcelvdh <marcelvdh@linux.com>

pkgname=claude-desktop-official
pkgver=1.30096.1
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
sha512sums=('a4e86e99618fc1fb779f0ea9deabbbea639df73b7d17b539ae8cb03a51a6f4f78c107e554c4a679292f8dc3ed63b047b7c7064919b0f8827e4a3931c8562bc20')

package() {
	bsdtar -xf "$srcdir/claude-desktop_${pkgver}_amd64.deb" -C "$srcdir"

	bsdtar -xf "$srcdir"/data.tar.* -C "$pkgdir/"

	install -Dm644 "$pkgdir/usr/share/doc/claude-desktop/copyright" \
		"$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
