# claude-desktop-official

Arch Linux `PKGBUILD` for the official Anthropic **Claude Desktop** client
(stable channel). It repackages Anthropic's upstream `.deb` into a native Arch
package.

## Install

### From a built release (no AUR needed)

Each tagged release ships a prebuilt package attached to the
[GitHub Release](../../releases). Install it directly:

```sh
sudo pacman -U <release-asset-url>
```

### Build it yourself

```sh
git clone https://github.com/marcelvdh/claude-desktop-official
cd claude-desktop-official
makepkg -si
```

## Automation

| Workflow | Trigger | What it does |
|---|---|---|
| [`update.yml`](.github/workflows/update.yml) | nightly (23:00 UTC) + manual | Checks Anthropic's APT repo for a newer version; if found, bumps the `PKGBUILD`, refreshes `sha512sums` (`updpkgsums`), regenerates `.SRCINFO`, builds to validate, and opens a PR. Opens a tracking issue on failure. |
| [`build.yml`](.github/workflows/build.yml) | PRs / push to `main` | Builds the package in an Arch container, lints with `namcap`, verifies `.SRCINFO` is in sync, and uploads the `*.pkg.tar.zst` artifact. |
| [`release.yml`](.github/workflows/release.yml) | push tag `v*` | Builds and attaches the package to a GitHub Release. |

### Cutting a release

After merging a nightly update PR:

```sh
git checkout main && git pull
git tag v<version>          # e.g. v1.18286.2
git push origin v<version>
```

### Notes

- The nightly PR is opened by `GITHUB_TOKEN`, so `build.yml` does **not**
  re-run on it automatically — the package is already built and validated inside
  the update run. To force CI to re-run on bot PRs, add a fine-grained PAT secret
  and use it for the checkout/push in `update.yml`.
- `scripts/latest-version.sh` is dependency-free (`curl`/`awk`/`sort`) and runs
  on any platform, so the version-detection logic can be tested locally.
