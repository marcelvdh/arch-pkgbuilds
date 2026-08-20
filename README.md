# arch-pkgbuilds

A personal collection of Arch Linux `PKGBUILD`s I build and trust, compiled in
CI as artifacts.

## Packages

| Package | Source |
|---|---|
| `claude-desktop-official` | own — repackages Anthropic's `.deb` |
| `google-chrome` | AUR (verbatim) |
| `docker-desktop` | AUR (verbatim) |

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
| `release.yml` | tag `<name>/v*` / manual | builds the tagged package and attaches it to a GitHub Release |

Each `packages/<name>/` folder is a pure mirror of the upstream package (PKGBUILD
plus its source files — nothing generated). Version-checking lives separately in
`updaters/<name>.sh` (apt-index packages share `scripts/apt-latest.sh`), run with
the package folder as its working directory.

## Release a package

```sh
git tag google-chrome/v151.0.7922.169
git push origin google-chrome/v151.0.7922.169
```

or run `release.yml` from the Actions tab and pick the package (it tags the
current `pkgver`).

## Add a package

```sh
scripts/add-aur.sh <name>     # vendors packages/<name>/ from the AUR
```

Review the PKGBUILD — you own the copy now. It builds and releases immediately;
the workflows auto-discover `packages/*/`, so there are no lists to edit. For
nightly version-bump PRs, add an `updaters/<name>.sh` that bumps its PKGBUILD to
the latest upstream version (optional; runs with the package folder as cwd).
