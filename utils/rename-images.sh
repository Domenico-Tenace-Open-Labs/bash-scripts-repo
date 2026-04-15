#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# rename_images.sh
# Rename all images in the current folder with a chosen name + UUID
# ---------------------------------------------------------------------------

set -euo pipefail

# Supported extensions
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "tiff" "tif" "webp" "svg" "heic" "heif" "avif" "raw" "cr2" "nef" "arw")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

generate_id() {
    # Generate a unique ID: try with uuidgen, fallback with /dev/urandom
    if command -v uuidgen &>/dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | head -c 12
    else
        cat /dev/urandom | LC_ALL=C tr -dc 'a-f0-9' | head -c 12
    fi
}

is_image() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}" # lowercase
    for e in "${IMAGE_EXTENSIONS[@]}"; do
        [[ "$ext" == "$e" ]] && return 0
    done
    return 1
}

sanitize_name() {
    # Convert spaces to underscores, remove unsafe characters
    echo "$1" | tr ' ' '_' | LC_ALL=C sed 's/[^a-zA-Z0-9_-]//g'
}

# ---------------------------------------------------------------------------
# Introduction
# ---------------------------------------------------------------------------

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║        Image Batch Renamer           ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "Current directory: ${YELLOW}$(pwd)${RESET}"
echo ""

# ---------------------------------------------------------------------------
# Preliminary scan: count images before asking anything
# ---------------------------------------------------------------------------

declare -a found_images=()

while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    # Skip hidden files and itself
    [[ "$filename" == .* ]] && continue
    [[ "$filename" == "rename_images.sh" ]] && continue
    if is_image "$filename"; then
        found_images+=("$file")
    fi
done < <(find . -maxdepth 1 -type f -print0 | sort -z)

total=${#found_images[@]}

if [[ $total -eq 0 ]]; then
    echo -e "${RED}No images found in this folder. Exiting.${RESET}"
    exit 0
fi

echo -e "Found ${GREEN}${total}${RESET} images:"
for img in "${found_images[@]}"; do
    echo -e "  • $(basename "$img")"
done
echo ""

# ---------------------------------------------------------------------------
# User input
# ---------------------------------------------------------------------------

while true; do
    read -rp "Base name for images (e.g. 'vacation_photo'): " base_name
    base_name=$(sanitize_name "$base_name")
    if [[ -z "$base_name" ]]; then
        echo -e "${RED}The name cannot be empty. Try again.${RESET}"
    else
        break
    fi
done

echo ""
echo -e "Images will be renamed as: ${CYAN}${base_name}_<id>.<ext>${RESET}"
read -rp "Confirm? [y/N] " confirm
echo ""

if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo -e "${YELLOW}Operation cancelled.${RESET}"
    exit 0
fi

# ---------------------------------------------------------------------------
# Rename
# ---------------------------------------------------------------------------

success=0
skipped=0

for file in "${found_images[@]}"; do
    filename=$(basename "$file")
    ext="${filename##*.}"
    ext="${ext,,}" # lowercase

    new_id=$(generate_id)
    new_name="${base_name}_${new_id}.${ext}"
    new_path="./${new_name}"

    # Collision handling (unlikely with UUID, but better to prevent)
    if [[ -e "$new_path" ]]; then
        echo -e "${YELLOW}  ⚠ Collision for ${new_name}, skipping.${RESET}"
        skipped=$((skipped + 1))
        continue
    fi

    mv "$file" "$new_path"
    echo -e "  ${GREEN}✓${RESET} ${filename} → ${new_name}"
    success=$((success + 1))
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Renamed: ${GREEN}${success}${RESET}"
[[ $skipped -gt 0 ]] && echo -e "  Skipped:    ${YELLOW}${skipped}${RESET}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
