#!/bin/sh
# SortCollections.pak - resort every Collections/*.txt file into the same
# order used for regular Roms browsing. MinUI's Y/X Collection feature only
# ever appends to these files (see appendToCollection() in minui.c), so
# items show up in "added order" with no way to resort them on-device.
# This re-sorts in place by the full "[xx かな]Title" filename, so the
# platform tag ([fc]/[ga]/[gb]/[gc]/[gg]/[sf]) naturally groups together
# first, then kana, then title, within each file.

COLLECTIONS_DIR="$SDCARD_PATH/Collections"
TAB="$(printf '\t')"
TMP="/tmp/sort_collections_tmp.txt"

for f in "$COLLECTIONS_DIR"/*.txt; do
	[ -f "$f" ] || continue
	[ "$(basename "$f")" = "map.txt" ] && continue

	: > "$TMP"
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		fname=$(basename "$line")
		printf '%s%s%s\n' "$fname" "$TAB" "$line" >> "$TMP"
	done < "$f"

	LC_ALL=C sort -t "$TAB" -k1,1 "$TMP" > "$TMP.sorted"

	: > "$f"
	while IFS= read -r sorted_line; do
		[ -z "$sorted_line" ] && continue
		echo "${sorted_line#*$TAB}" >> "$f"
	done < "$TMP.sorted"
done

rm -f "$TMP" "$TMP.sorted"
