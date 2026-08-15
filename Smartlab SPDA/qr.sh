#!/bin/bash

# Description: Reads links from links.txt, sorts existing folders alphabetically and appends a QR code (QR.png) inside each folder.

set -euo pipefail

INPUT_FILE="links.txt"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: $INPUT_FILE not found."
    exit 1
fi

# Check if qrencode is installed
if ! command -v qrencode &> /dev/null; then
    echo "Error: qrencode is not installed."
    exit 1
fi

# 1. Read links from the file
#    Split on commas and spaces, trim whitespace, remove empty lines.
mapfile -t links < <(tr ',' '\n' < "$INPUT_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$')

if [[ ${#links[@]} -eq 0 ]]; then
    echo "No links found in $INPUT_FILE."
    exit 0
fi

# 2. Get existing directories in the current working directory,
#    sorted alphabetically. Exclude hidden directories and '.' itself.
mapfile -t folders < <(find . -maxdepth 1 -type d ! -name "." ! -name ".*" -printf "%f\n" | sort)

if [[ ${#folders[@]} -eq 0 ]]; then
    echo "No folders found in the current directory."
    exit 0
fi

# 3. Determine how many pairs to process
link_count=${#links[@]}
folder_count=${#folders[@]}
pair_count=$(( link_count < folder_count ? link_count : folder_count ))

if [[ $pair_count -eq 0 ]]; then
    echo "Nothing to process (no links or no folders)."
    exit 0
fi

# mismatch warning
if [[ $link_count -ne $folder_count ]]; then
    echo "Warning: Number of links ($link_count) differs from number of folders ($folder_count)."
    echo "Only the first $pair_count pairs will be processed."
fi

echo "Processing $pair_count pairs..."

# 4. Generate QR code for each pair
for (( i=0; i<pair_count; i++ )); do
    link="${links[i]}"
    folder="${folders[i]}"
    
    echo "Pair $((i+1)): '$link' → folder '$folder'"
    qrencode -o "$folder/QR.png" "$link"
done

echo "All QR codes generated."
