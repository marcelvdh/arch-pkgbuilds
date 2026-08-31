# Pinned upstream signing keys

Used by `scripts/apt-index.sh` — on behalf of both `updaters/*.sh` and
`verifiers/*.sh` — to verify signed apt metadata. Only `google-chrome` and
`claude-desktop` are distributed this way; the other packages are cross-checked
against unsigned checksum files (see the README).

Each key is vendored byte-for-byte from the URL the vendor's own documentation
tells users to download it from.

| File | Owner (uid) | Primary fingerprint | Downloaded from | Documented at |
|---|---|---|---|---|
| `google-linux.asc` | Google Inc. (Linux Packages Signing Authority) `<linux-packages-keymaster@google.com>` | `EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796` | <https://dl.google.com/linux/linux_signing_key.pub> | <https://www.google.com/linuxrepositories/> |
| `anthropic-apt.asc` | Anthropic Claude Code Release Signing `<security@anthropic.com>` | `31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE` | <https://downloads.claude.ai/claude-desktop/key.asc> | <https://code.claude.com/docs/en/desktop-linux> (fingerprint printed in the docs) |

Google signs with rotating subkeys under the primary key above; the vendored
bundle carries them, so subkey rotation needs no action here. A verifier
failing with a signature error after a vendor key rotation means this file
needs a refresh from the same documented URL — re-check the fingerprint
against the vendor's documentation before replacing it.

Sourcing policy: keys come only from a URL the vendor documents, on the
vendor's own domain. 
