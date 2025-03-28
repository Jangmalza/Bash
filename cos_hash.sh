#!/bin/bash

COS_PATH=""
OUTPUT_FILE=""
TEMP_FILE=""

files=$(coscli ls -r "${COS_PATH}" | awk -F'|' 'NR>2 {gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')

for file in $files; do
    coscli hash "${COS_PATH}${file}" --type md5 2>/dev/null | grep -oE '[0-9a-f]{32}' >> "$TEMP_FILE"
done

sort -u "$TEMP_FILE" -o "$OUTPUT_FILE"

rm -f "$TEMP_FILE"