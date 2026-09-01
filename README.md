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
sudo pacman-key --lsign-key 6CBA620FB74D4F08AA3A998F09B2AA5FF665F97A
```

Both steps are needed: `SigLevel = Required` implies `TrustedOnly`, so a key
that is imported but not locally signed leaves pacman refusing the database
with `unknown trust`.

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
| `check.yml` | PR / push to `main` | builds the affected packages in an Arch container to prove they still compile; publishes nothing |
| `update.yml` | nightly / manual | checks every package for a newer upstream version and opens a version-bump PR per package |
| `release.yml` | push to `main` / tag `<name>/v*` / manual | publishes any package whose current `pkgver` has no release yet, and refreshes the pacman repo database |

`check.yml` is the check and `release.yml` is the publisher: only `release.yml`
produces something installable. They never both build the same change — a
PKGBUILD edit belongs to `release.yml`, everything else to `check.yml`.

Each `packages/<name>/` folder is self-contained (PKGBUILD plus its source
files — nothing generated). Version-checking lives separately in
`updaters/<name>.sh`. `verifiers/<name>.sh` cross-checks the PKGBUILD sums against
the checksums upstream publishes; all three workflows run it, so nothing builds,
releases or reaches the pacman repo on a sum nobody checked. Both share
`scripts/apt-index.sh` for apt-hosted packages, which fetches the `Packages`
index once and verifies its InRelease signature against the keys pinned in
`keys/`.

Every script in `updaters/` and `verifiers/` runs with the package folder as its
working directory, and those in `scripts/` are shared helpers they call.

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

Keys in `keys/` are vendored byte-for-byte from the URL each vendor's own
documentation points at — never from a key server. `keys/README.md` records the
fingerprint, download URL and documentation page for each.

An apt index only lists the current version, so a verifier that finds no
checksum for the pinned version reports it and passes — that is a superseded
release, not a mismatch. A signature or network failure still fails hard.

## Release a package

```sh
git tag google-chrome/v151.0.7922.169
git push origin google-chrome/v151.0.7922.169
```

or run `release.yml` from the Actions tab: leave the package blank to publish
whatever has no release yet, or name one to republish it — which is also how you
ship a `pkgrel`-only change, since the tag already exists.

`release.yml` picks what to build by asking which `pkgver`s have no release
(`scripts/unreleased.sh`) rather than by inspecting what a push changed, so a
release that fails or never ran simply happens on the next push to `main`.

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

The nightly opens its PRs with a GitHub App token (`UPDATER_APP_ID` and
`UPDATER_APP_PRIVATE_KEY` secrets). A PR opened with the default `GITHUB_TOKEN`
is authored by `github-actions[bot]`, which counts as a first-time contributor,
so its checks would sit unstarted until approved by hand.
