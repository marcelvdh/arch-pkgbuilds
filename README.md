# arch-pkgbuilds

A personal pacman repository. Every package here is built from its `PKGBUILD`
in GitHub Actions, signed, and published as a GitHub release; a rolling `repo`
release carries the pacman database.

## Packages

| Package | Source |
|---|---|
| `claude-code` | forked from AUR |
| `claude-desktop` | own — repackages Anthropic's `.deb` |
| `google-chrome` | forked from AUR |
| `docker-desktop` | forked from AUR |
| `docker-sbx` | forked from AUR |
| `winbox` | forked from AUR |

## Install

Import the signing key and trust it locally, once per machine:

```sh
curl -LO https://raw.githubusercontent.com/marcelvdh/arch-pkgbuilds/main/arch-pkgbuilds.pub
sudo pacman-key --add arch-pkgbuilds.pub
sudo pacman-key --lsign-key 6CBA620FB74D4F08AA3A998F09B2AA5FF665F97A
```

Both steps matter: `SigLevel = Required` implies `TrustedOnly`, and a key that
is imported but not locally signed makes pacman reject the database with
`unknown trust`.

Append to `/etc/pacman.conf`:

```ini
[arch-pkgbuilds]
SigLevel = Required
Server = https://github.com/marcelvdh/arch-pkgbuilds/releases/download/repo
```

Then `pacman -Syu` and `pacman -S <package>`. From there packages upgrade with
the rest of the system.

## Layout

```
packages/<name>/     PKGBUILD plus its vendored source files; nothing generated
updaters/<name>.sh   bumps the PKGBUILD to the latest upstream version (optional)
verifiers/<name>.sh  checks the pinned sha256 against what upstream publishes (optional)
scripts/             shared helpers the above call
keys/                upstream apt signing keys, pinned; see keys/README.md
```

Updaters and verifiers run with the package folder as their working directory.
The workflows discover `packages/*/` on their own, so adding a package is a
matter of adding a folder.

## Workflows

| Workflow | Runs on | Does |
|---|---|---|
| `update.yml` | nightly at 23:00 UTC, or by hand | opens a version-bump PR per package that has a newer upstream release |
| `check.yml` | pull requests, pushes to `main` | builds the affected packages to prove they still compile; publishes nothing |
| `release.yml` | pushes to `main`, tags `<name>/v*`, or by hand | publishes packages and refreshes the pacman repo |

All three run in an `archlinux:latest` container as an unprivileged `builder`
user, and all three run the package's verifier before building, so nothing is
compiled, released or served on a checksum nobody cross-checked.

### Nightly update

For each package with an updater: run it, and stop if `pkgver` did not move.
Otherwise `updpkgsums`, run the verifier, and open a PR from branch
`autoupdate/<name>-<version>` containing the single changed PKGBUILD. The
commit is made through the GitHub API with a GitHub App token
(`UPDATER_APP_ID`, `UPDATER_APP_PRIVATE_KEY`), which gets it signed and lets
the PR's checks start without manual approval — a PR from
`github-actions[bot]` would sit waiting as a first-time contributor. A failed
run opens an issue titled `Update failed: <name> on <date>`, once.

A closed PR does not block a new one: only an open PR on the same branch does.
Merged PRs need nothing either, since `main` then carries the version.

### Check

On a pull request, only the packages whose folders changed are built; if
anything outside `packages/` changed, everything is. Pushes to `main` that
touch only a PKGBUILD or Markdown are skipped, because `release.yml` builds
those.

### Release

`release.yml` does not look at what a push changed. It asks which packages have
no release for their current `pkgver` (`scripts/unreleased.sh`) and publishes
those, so a release that failed or never ran happens on the next push to
`main`. Per package: verify, build, create tag `<name>/v<pkgver>`, create the
release, upload the `.pkg.tar.zst`.

The `repo` job then rebuilds the pacman repository from scratch: download every
package's current release, sign each with the repository key (`SIGNING_KEY`),
`repo-add --sign`, and upload the lot to the rolling `repo` release. It refuses
to publish a database that references a package with no release.

To release by hand, push a tag or run the workflow from the Actions tab: blank
publishes whatever has no release yet, `all` republishes everything, a name
republishes that one — which is also how a `pkgrel`-only change ships, since
the tag already exists.

```sh
git tag google-chrome/v151.0.7922.169
git push origin google-chrome/v151.0.7922.169
```

## Verification

"Verified" means one of two things here:

| Package | Cross-checked against | Signed? |
|---|---|---|
| `google-chrome`, `claude-desktop` | apt `InRelease` → `Packages` → `.deb` | yes, against a key pinned in `keys/` |
| `claude-code`, `docker-desktop`, `docker-sbx`, `winbox` | a checksum file next to the artifact | no |

The unsigned checks catch a corrupt download and `updpkgsums` hashing
something other than what upstream shipped. They do not defend against a
compromised CDN or publisher: whoever can serve a bad artifact can serve a
matching hash. Only the signed apt path does that.

Keys in `keys/` are vendored byte-for-byte from the URL each vendor's own
documentation points at, never from a key server.

An apt index only lists the current version. A verifier that finds no checksum
for the pinned version reports a superseded release and passes; a signature or
network failure fails hard.

## Add a package

```sh
scripts/add-aur.sh <name>     # vendors packages/<name>/ from the AUR
```

Review the PKGBUILD; it is yours now. It builds and releases on the next push
to `main`. Add `updaters/<name>.sh` for nightly bump PRs and
`verifiers/<name>.sh` if upstream publishes checksums; a package without a
verifier logs a warning on every build.

## Build locally

```sh
cd packages/<name>
makepkg -si
```
