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

`update.yml` opens its PRs with a GitHub App token, from the `UPDATER_APP_ID`
and `UPDATER_APP_PRIVATE_KEY` secrets. This is not about privilege — a PR opened
with the built-in `GITHUB_TOKEN` is barred from starting workflow runs, so its
checks sit there waiting to be approved by hand. Grant the app **Contents:
read & write** and **Pull requests: read & write** on this repo. Without the
secrets the nightly still checks, verifies and builds; only the PR step fails.

Each `packages/<name>/` folder is self-contained (PKGBUILD plus its source
files — nothing generated). Version-checking lives separately in
`updaters/<name>.sh`, run with the package folder as its working directory.
`verifiers/<name>.sh` (same contract) cross-checks the PKGBUILD sums against the
checksums upstream publishes; all three workflows run it, so nothing builds,
releases or reaches the pacman repo on a sum nobody checked. Both share
`scripts/apt-index.sh` for apt-hosted packages, which fetches the `Packages`
index once and verifies its InRelease signature against the keys pinned in
`keys/`.

Two levels of trust hide behind the word "verified", and it is worth being
precise about which one a package gets:

| Package | Cross-checked against | Signed? |
|---|---|---|
| `google-chrome`, `claude-desktop` | apt `InRelease` → `Packages` → `.deb` | yes, against a pinned key |
| `claude-code`, `docker-desktop`, `docker-sbx`, `winbox` | a checksum file next to the artifact | no |

The unsigned ones catch a corrupt or truncated download, and they catch
`updpkgsums` hashing something other than what upstream meant to ship. They do
not defend against a compromised CDN or publisher account: whoever can serve the
bad artifact can serve a matching hash. Only the signed apt path does that.

An apt index only lists the current version, so a verifier that finds no
checksum for the pinned version reports it and passes — that is a superseded
release, not a mismatch. A signature or network failure still fails hard.

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
the latest upstream version (optional; runs with the package folder as cwd), and
a `verifiers/<name>.sh` if upstream publishes checksums worth cross-checking.
Both are optional, but a package with no verifier logs a CI warning every time
it builds.
