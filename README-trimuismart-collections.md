# Collection management (Y/X) + longer/optional auto-sleep — Trimui Smart

A small patch for [MinUI](https://github.com/shauninman/MinUI) (archived 2025-11-27), plus one optional drop-in Tools pak. **`trimuismart` (original Trimui Smart) only.**

- Add/remove roms from a Collection directly from the rom list (Y/X), without pulling the SD card
- Auto-sleep extended from 30 seconds to 5 minutes, with an on-device toggle to disable it entirely — useful since the original Trimui Smart can't wake from sleep, so the short default timeout meant losing your session (full power cycle) just from pausing to think
- *(bonus, not part of the patch)* a "Random" Tools pak that launches a random rom from across every installed system

## What it does

**Add to a collection** — while browsing the rom list, press **Y** on a highlighted rom to open a popup listing the existing `Collections/*.txt` files.

- Up/Down: move selection
- A: append the rom to the selected collection (skips if already present)
- B: cancel, no changes

**Remove from a collection** — while browsing *inside* a collection, press **X** on a highlighted rom to open a confirm popup (rom name on top, "Remove from collection?" below).

- A: remove it
- B: cancel, no changes

Naming a brand new collection is **not** done on-device — MinUI has no on-screen keyboard, so this patch doesn't add one either. Instead, just create empty `.txt` files under `Collections/` with whatever names you like ahead of time (any name works, e.g. `Collections/fav.txt`); they show up in the Y-button popup like any other collection, even while empty. Deleting a whole collection (not just an item in it) is also left to doing it on the SD card directly — not worth the on-device UI for something you do rarely.

**Auto-sleep: longer, and optional** — auto-sleep now kicks in after 5 minutes of no input instead of 30 seconds. To turn it off entirely (manual sleep via the sleep button still works), drop the included `Sleep 5min.pak` folder into `Tools/trimuismart/` and select it from the Tools menu; it flips a flag and renames itself to `Sleep Off.pak` so the menu entry itself always shows which state you're in. Select it again to go back to the 5-minute default.

**Bonus: Random.pak** — not a source patch at all, just a drop-in `Tools/trimuismart/Random.pak/launch.sh` shell script. Picks and launches a random rom from across every system folder under `Roms/`. Caches the candidate list next to itself the first time it runs (`cache.txt`, in the same pak folder); delete that file if you add/remove roms later and want it to pick up the new set.

## Quick install (prebuilt binaries, no building required)

Grab `minui.elf` and `minarch.elf` from the [Releases](../../releases) page (both link the sleep-delay code independently, so both need replacing for the 5-minute default to apply everywhere — menu *and* in-game).

1. On your SD card, back up the existing binaries: rename `.system/trimuismart/bin/minui.elf` and `minarch.elf` to e.g. `minui.elf.orig` / `minarch.elf.orig`
2. Copy the downloaded `minui.elf` and `minarch.elf` into `.system/trimuismart/bin/`
3. Create whatever empty `.txt` files you want under `Collections/` (skip this if you already have collections — those show up too)
4. *(optional)* drop `Sleep 5min.pak` into `Tools/trimuismart/` for the sleep on/off toggle, and/or `Random.pak` for the random-rom launcher — both from the Release assets
5. Put the card back in your Trimui Smart and boot

To revert, just copy the `.orig` binaries back over.

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

- Y/X collection management lives entirely in `workspace/all/minui/minui.c`, gated behind `strcmp(PLATFORM, "trimuismart")==0` since a few other platforms also expose physical Y/X buttons — building for those is unaffected
- The sleep change touches `workspace/all/common/defines.h`, `api.c`, `minui.c`, and `minarch.c` — a new `NO_AUTOSLEEP_PATH` flag file is checked once at startup in both `minui.c` and `minarch.c` (each links `api.c` independently, hence the two call sites) and calls the existing-but-previously-unused `PWR_disableAutosleep()` API; `SLEEP_DELAY` in `api.c` moved from 30000 to 300000ms. Neither change is platform-gated since the sleep API is generic, but the on-device toggle pak (`Sleep 5min.pak`) is `trimuismart`-only by virtue of only being distributed for that platform's `Tools/` folder
- `Random.pak` has no C code at all — see "Bonus" above
- Upstream MinUI has no declared license; this fork/patch is shared in the same spirit as the existing MinUI fork ecosystem (NextUI, MyMinUI, minui-favorites, etc.)

## Tested

Confirmed working on real hardware (Trimui Smart, original/non-Pro).
