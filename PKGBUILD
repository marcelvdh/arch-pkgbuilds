pkgname=claude-desktop-official
pkgver=1.17377.1
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
sha512sums=('a904d685159df206d9a07b0ec102c64f0532243b04d0da755efdee9c8d4dae75ef3cc065f6fef6641a7e228a5291b734b0a870867ddbab447e31e35f578eed17')

package() {
	bsdtar -xf "claude-desktop_${pkgver}_amd64.deb" -C "$srcdir"

	bsdtar -xf "$srcdir"/data.tar.* -C "$pkgdir/"

	install -Dm644 "$pkgdir/usr/share/doc/claude-desktop/copyright" \
		"$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}