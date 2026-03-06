#!/usr/bin/env bash

# convert-to-webp.sh
# Converts all images in the current folder (and subfolders) to .webp format
# Dependencies: cwebp (webp package) or ffmpeg
# Usage: bash convert-to-webp.sh [quality 1-100, default 85]

set -euo pipefail

QUALITY=${1:-85}
SUPPORTED_FORMATS=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "tif" "avif" "heic" "heif")
CONVERTED=0
SKIPPED=0
ERRORS=0

# Check that at least one of the required tools is available
if command -v cwebp &>/dev/null; then
  TOOL="cwebp"
elif command -v ffmpeg &>/dev/null; then
  TOOL="ffmpeg"
else
  echo "Error: install 'cwebp' (webp package) or 'ffmpeg' before proceeding."
  echo "  macOS:  brew install webp"
  echo "  Ubuntu: sudo apt install webp"
  exit 1
fi

echo "Tool used: $TOOL"
echo "Quality: $QUALITY"
echo "Folder: $(pwd)"
echo "-------------------------------------------"

convert_image() {
  local input="$1"
  local output="${input%.*}.webp"

  # Skip if output already exists and is newer than input
  if [[ -f "$output" && "$output" -nt "$input" ]]; then
    echo "  [SKIP] $input (already converted)"
    ((SKIPPED++)) || true
    return
  fi

  # Skip if the file is already a .webp
  if [[ "${input##*.}" == "webp" ]]; then
    echo "  [SKIP] $input (already .webp)"
    ((SKIPPED++)) || true
    return
  fi

  echo "  [CONV] $input → $output"

  if [[ "$TOOL" == "cwebp" ]]; then
    if cwebp -q "$QUALITY" "$input" -o "$output" &>/dev/null; then
      ((CONVERTED++)) || true
    else
      echo "  [ERR]  Error on: $input"
      ((ERRORS++)) || true
    fi
  else
    if ffmpeg -i "$input" -quality "$QUALITY" "$output" -y &>/dev/null; then
      ((CONVERTED++)) || true
    else
      echo "  [ERR]  Error on: $input"
      ((ERRORS++)) || true
    fi
  fi
}

# Build find pattern for all supported formats
FIND_ARGS=()
for fmt in "${SUPPORTED_FORMATS[@]}"; do
  FIND_ARGS+=(-o -iname "*.${fmt}")
done
# Remove the first -o
FIND_ARGS=("${FIND_ARGS[@]:1}")

# Scan and convert
while IFS= read -r -d '' file; do
  convert_image "$file"
done < <(find . \( "${FIND_ARGS[@]}" \) -type f -print0)

echo "-------------------------------------------"
echo "Converted: $CONVERTED | Skipped: $SKIPPED | Errors: $ERRORS"
