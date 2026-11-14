#!/bin/sh
# Random.pak - launch a random ROM from across all systems

ROMS_PATH="$SDCARD_PATH/Roms"
PAKS_PATH="$SYSTEM_PATH/paks"
CACHE_LIST="$(dirname "$0")/cache.txt"
TMP_LIST="/tmp/random_pak_candidates.txt"

# ROM追加・削除はほぼ無い前提でキャッシュ。ROM構成を変えたら
# cache.txt をこのpakフォルダから削除すれば次回起動時に再構築される。
if [ ! -f "$CACHE_LIST" ]; then
	find "$ROMS_PATH" -mindepth 2 -maxdepth 2 -type f \
		! -iname "gamelist.xml" \
		! -iname "gamelist.xml.old" \
		! -iname "COPYING*" \
		! -iname "LICENSE*" \
		! -iname "*.old" \
		! -iname "*.db" \
		! -iname "*.bin" \
		! -iname "*.srm" \
		! -iname "*.state*" \
		! -iname "*.sv0" \
		! -iname "*.sv1" \
		! -iname "*.spc" \
		> "$CACHE_LIST"
fi
cp "$CACHE_LIST" "$TMP_LIST"

COUNT=$(wc -l < "$TMP_LIST")
if [ "$COUNT" -lt 1 ]; then
	rm -f "$TMP_LIST" "$CACHE_LIST"
	exit 1
fi

# /dev/urandom can be unavailable/broken on this device, and PID alone
# increments by small steps between launches -- either one on its own
# can make picks repeat in a short, predictable cycle. Mix in a
# persistent counter (always changes) scrambled with a large odd
# multiplier so the low bits used for the modulo are well spread out.
STATE_FILE="$(dirname "$0")/.counter"
CTR=0
[ -f "$STATE_FILE" ] && CTR=$(cat "$STATE_FILE" 2>/dev/null)
case "$CTR" in ''|*[!0-9]*) CTR=0 ;; esac
CTR=$(( (CTR + 1) % 1000000 ))
echo "$CTR" > "$STATE_FILE"

URANDOM_SEED=$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ')
[ -z "$URANDOM_SEED" ] && URANDOM_SEED=0

SEED=$(( (CTR * 2654435761) + URANDOM_SEED + ($$ * 97) ))
SEED=$(( SEED < 0 ? -SEED : SEED ))
N=$(( (SEED % COUNT) + 1 ))
ROM_PATH=$(sed -n "${N}p" "$TMP_LIST")
rm -f "$TMP_LIST"

SYS_DIR=$(dirname "$ROM_PATH")
SYS_NAME=$(basename "$SYS_DIR")
TAG=$(echo "$SYS_NAME" | sed 's/.*(\(.*\)).*/\1/')

EMU_LAUNCH="$SDCARD_PATH/Emus/$PLATFORM/$TAG.pak/launch.sh"
if [ ! -f "$EMU_LAUNCH" ]; then
	EMU_LAUNCH="$PAKS_PATH/Emus/$TAG.pak/launch.sh"
fi

if [ ! -f "$EMU_LAUNCH" ]; then
	exit 1
fi

"$EMU_LAUNCH" "$ROM_PATH"
