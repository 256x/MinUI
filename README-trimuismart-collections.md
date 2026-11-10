# Collection management (Y/X buttons) — Trimui Smart

A small patch for [MinUI](https://github.com/shauninman/MinUI) (archived 2025-11-27) that adds a way to add/remove roms from a Collection directly from the rom list, without pulling the SD card. **`trimuismart` (original Trimui Smart) only.**

## What it does

**Add to a collection** — while browsing the rom list, press **Y** on a highlighted rom to open a popup listing the existing `Collections/*.txt` files.

- Up/Down: move selection
- A: append the rom to the selected collection (skips if already present)
- B: cancel, no changes

**Remove from a collection** — while browsing *inside* a collection, press **X** on a highlighted rom to open a confirm popup (rom name on top, "Remove from collection?" below).

- A: remove it
- B: cancel, no changes

Naming a brand new collection is **not** done on-device — MinUI has no on-screen keyboard, so this patch doesn't add one either. Instead, just create empty `.txt` files under `Collections/` with whatever names you like ahead of time (any name works, e.g. `Collections/fav.txt`); they show up in the Y-button popup like any other collection, even while empty. Deleting a whole collection (not just an item in it) is also left to doing it on the SD card directly — not worth the on-device UI for something you do rarely.

## Quick install (prebuilt binary, no building required)

Grab `minui.elf` from the [Releases](../../releases) page.

1. On your SD card, back up the existing binary: rename `.system/trimuismart/bin/minui.elf` to e.g. `minui.elf.orig`
2. Copy the downloaded `minui.elf` into `.system/trimuismart/bin/`
3. Create whatever empty `.txt` files you want under `Collections/` (skip this if you already have collections — those show up too)
4. Put the card back in your Trimui Smart and boot

To revert, just copy `minui.elf.orig` back over `minui.elf`.

## Building from source

1. Clone [shauninman/MinUI](https://github.com/shauninman/MinUI)
2. Apply `trimuismart-collections.patch` from the Releases page:
   ```
   cd MinUI
   git apply /path/to/trimuismart-collections.patch
   ```
3. With Docker running:
   ```
   make trimuismart
   ```
   This also tries to build libretro cores for other systems and may exit non-zero on an unrelated `fceumm` patch mismatch — `workspace/all/minui/build/trimuismart/minui.elf` is produced fine regardless.

### Gotchas you might hit building

- **Toolchain Docker image build fails on a TLS error talking to `buildroot.org`** (`GnuTLS: ... Error in protocol version`): the container's old `debian:stretch-slim` GnuTLS can't negotiate with buildroot.org's current TLS config. Download `buildroot-2016.05.tar.gz` yourself on the host and drop it in `toolchains/trimuismart-toolchain/support/` before building — `build-toolchain.sh` already prefers a local copy if one's present.
- **"cannot attach stdin to a TTY-enabled container"**: happens if you run the build from a non-interactive shell (CI, scripts). Drop `-it` from the `docker run` call in `makefile.toolchain`'s `build` target (not needed from a normal interactive terminal).

## Scope / notes

- The entire change lives in `workspace/all/minui/minui.c` (one file, ~280 lines in the patch)
- `minui.c` is shared across all platforms, but the new code is gated behind `strcmp(PLATFORM, "trimuismart")==0` since a few other platforms also expose physical Y/X buttons — building for those is unaffected
- Upstream MinUI has no declared license; this fork/patch is shared in the same spirit as the existing MinUI fork ecosystem (NextUI, MyMinUI, minui-favorites, etc.)

## Tested

Confirmed working on real hardware (Trimui Smart, original/non-Pro).
