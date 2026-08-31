# arch-pkgbuilds

A personal collection of Arch Linux `PKGBUILD`s I build and trust, compiled in
CI as artifacts.

## Packages

| Package | Source |
|---|---|
| `claude-code` | forked from AUR |
| `claude-desktop` | own — repackages Anthropic's `.deb` |
| `google-chrome` | forked from AUR |
| `docker-desktop` | forked from AUR |
| `docker-sbx` | forked from AUR |
| `winbox` | forked from AUR |

## Install via pacman

One time per machine, import the signing key and trust it locally:

```sh
curl -LO https://raw.githubusercontent.com/marcelvdh/arch-pkgbuilds/main/arch-pkgbuilds.pub
sudo pacman-key --add arch-pkgbuilds.pub
sudo pacman-key --lsign-key FINGERPRINT
```

Then append to `/etc/pacman.conf`:

```ini
[arch-pkgbuilds]
SigLevel = Required
Server = https://github.com/marcelvdh/arch-pkgbuilds/releases/download/repo
```

Then `pacman -Syu` to sync and `pacman -S <package>` to install; installed
packages upgrade with the rest of the system from then on. The `repo` rolling
release carries the repo database and every package at its current `pkgver`,
refreshed by `release.yml` after each release. Packages and the database are
signed in CI with the key above (`arch-pkgbuilds.pub`, private half held only
as an Actions secret), so pacman rejects anything not signed by it.

## Build one locally

```sh
cd packages/<name>
makepkg -si
```

## CI

| Workflow | Trigger | What it does |
|---|---|---|
| `build.yml` | PR / push | builds every package in an Arch container and uploads each as an artifact |
| `update.yml` | nightly / manual | checks every package for a newer upstream version and opens a version-bump PR per package |
| `release.yml` | merge to `main` touching a PKGBUILD / tag `<name>/v*` / manual | builds the package, attaches it to a GitHub Release, and refreshes the pacman repo database |

Each `packages/<name>/` folder is self-contained (PKGBUILD plus its source
files — nothing generated). Version-checking lives separately in
`updaters/<name>.sh` (apt-index packages share `scripts/apt-latest.sh`), run with
the package folder as its working directory.

## Release a package

```sh
git tag google-chrome/v151.0.7922.169
git push origin google-chrome/v151.0.7922.169
```

or run `release.yml` from the Actions tab: enter a package name, or leave it
blank to release every package at its current `pkgver`.

## Add a package

```sh
scripts/add-aur.sh <name>     # vendors packages/<name>/ from the AUR
```

Review the PKGBUILD — you own the copy now. It builds and releases immediately;
the workflows auto-discover `packages/*/`, so there are no lists to edit. For
nightly version-bump PRs, add an `updaters/<name>.sh` that bumps its PKGBUILD to
the latest upstream version (optional; runs with the package folder as cwd).
