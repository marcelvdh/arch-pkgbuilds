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
scripts/lib.sh       shared helpers; every updater and verifier sources it
scripts/             the entry points the workflows call
keys/                upstream apt signing keys, pinned; see keys/README.md
```

Updaters and verifiers run with the package folder as their working directory
and source `scripts/lib.sh`, which gives them `pkgbuild`, `set_pkgver`,
`check_sum` and the signed-apt helpers.

The workflows discover `packages/*/` on their own, so adding a package is a
matter of adding a folder.

## Workflows

| Workflow | Runs on | Does |
|---|---|---|
| `update.yml` | nightly at 23:00 UTC, or by hand | opens a version-bump PR per package that has a newer upstream release; it merges itself once checked |
| `check.yml` | pull requests, pushes to `main` | builds the affected packages to prove they still compile; publishes nothing |
| `release.yml` | pushes to `main` that change a PKGBUILD, daily at 11:00 UTC, tags `<name>/v*`, or by hand | publishes packages |
| `repo.yml` | each finished `release.yml` run, or by hand | rebuilds the pacman repo from the releases |

The jobs that build run in an `archlinux:latest` container as an unprivileged
`builder` user, and run the package's verifier first, so nothing is compiled,
released or served on a checksum nobody cross-checked.

### Nightly update

For each package with an updater: run it, and stop if `pkgver` did not move.
Otherwise `updpkgsums`, run the verifier, and open a PR from branch
`autoupdate/<name>` containing the single changed PKGBUILD. The commit is made
through the GitHub API (blob, tree, commit, then the branch) with a GitHub App
token (`UPDATER_APP_ID`,
`UPDATER_APP_PRIVATE_KEY`), which gets it signed and lets the PR's checks
start without manual approval — a PR from `github-actions[bot]` would sit
waiting as a first-time contributor. A failed run is reported by GitHub's
own email for failed scheduled workflows; issues are disabled on this repo.

There is one branch per package. A newer version force-updates it and
retitles the PR, so at most one bump per package waits at a time. The branch
moves straight from the old bump to the new one: were it reset to `main`
first, GitHub would close the PR for having no changes. The app
enables auto-merge on the PR; it merges when `check.yml` passes and stays open
when it does not. A bump PR is not reviewed by hand: its diff is version and
checksum lines the verifier already cross-checked, and `check.yml` confirms
nothing else changed.

This needs the repository settings *Allow auto-merge* and *Automatically
delete head branches*, and a ruleset on `main` requiring the `result` check
with a bypass for admins so direct pushes still work. Leave *Require branches
to be up to date before merging* off: each bump touches a different file, and
with it on every merge would stall the other open bumps.

### Check

On a pull request, only the packages whose folders changed are built; if
anything outside `packages/` changed, everything is. Pushes to `main` that
touch only a PKGBUILD or Markdown are skipped, because `release.yml` builds
those.

A PR opened by a bot must also pass `scripts/check-bump.sh`: one PKGBUILD
changed, and only its `pkgver`, `pkgrel`, `_revision` and `sha256sums` lines.
The script is taken from the base branch, not the PR, so a PR cannot loosen
its own check.
The `result` job reports the outcome of all jobs as the single check the
`main` ruleset requires.

### Release

On a push to `main`, `release.yml` publishes the packages whose PKGBUILD the
push changed, so a run named after a bump PR builds that package and nothing
else; a `pkgrel` bump ships the same way. Runs queue per package, so bumps of
different packages merged together release side by side. A daily run
publishes whatever has no release yet, so a failed release is retried and,
being scheduled, emails the owner when it fails again. Per package: verify,
build, create tag `<name>/v<pkgver>`, create the release, upload the
`.pkg.tar.zst`.

When a release run finishes, `repo.yml` rebuilds the pacman repository from
scratch off the latest `main`: download every package's current release, sign
each with the repository key (`SIGNING_KEY`), `repo-add --sign`, and upload
the lot to the rolling `repo` release. Rebuilds queue one at a time; GitHub
keeps only the newest waiting run and cancels the others, which loses
nothing since every rebuild covers every package. If a package has no release
for its `pkgver` yet, the rebuild leaves the database as it is rather than
publish one without it; that release's own run triggers the next rebuild.

Assets go up through `scripts/gh-upload.sh`. `gh` has no HTTP timeout, so a
connection to `uploads.github.com` that goes quiet mid-transfer would hang the
job until the 6h limit; each file gets a budget sized to it instead, and a
stalled attempt is retried. Retries are per file, not per batch, because `gh`
fails a whole argument list when any one asset errors and the endpoint returns
sporadic `HTTP 500`s. `GH_UPLOAD_ATTEMPTS`, `GH_UPLOAD_JOBS` and
`GH_UPLOAD_TIMEOUT` override the defaults.

To release by hand, push a tag or run the workflow from the Actions tab: blank
publishes whatever has no release yet (the way to catch up after a failed
release), `all` republishes everything, a name republishes that one. Running
`repo.yml` by hand rebuilds the database without building anything.

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
