#!/bin/sh
# ToggleSleep.pak - flips the auto-sleep flag, and renames itself to show the
# resulting state right in the Tools menu (same self-rename trick Bootlogo.pak uses)

FLAG="$SHARED_USERDATA_PATH/disable-autosleep"
SELF_DIR="$(dirname "$0")"
PARENT_DIR="$(dirname "$SELF_DIR")"

if [ -f "$FLAG" ]; then
	rm -f "$FLAG"
	mv "$SELF_DIR" "$PARENT_DIR/Sleep 5min.pak"
else
	touch "$FLAG"
	mv "$SELF_DIR" "$PARENT_DIR/Sleep Off.pak"
fi
