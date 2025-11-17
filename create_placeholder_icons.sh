#!/bin/bash
# Script to create placeholder icons for the Beszel Agent package
# Requires ImageMagick (convert command)

set -e

ICON_DIR="icons"

echo "Creating placeholder icons..."

# Check if ImageMagick is available
if ! command -v convert &> /dev/null; then
    echo "WARNING: ImageMagick not found. Creating placeholder files instead."
    echo "Please replace these with actual PNG icons before building the package."

    # Create placeholder files
    echo "PNG placeholder - 72x72" > "$ICON_DIR/PACKAGE_ICON.PNG"
    echo "PNG placeholder - 256x256" > "$ICON_DIR/PACKAGE_ICON_256.PNG"

    echo "Placeholder files created. Replace with actual icons."
    exit 0
fi

# Create 72x72 icon
convert -size 72x72 xc:lightblue \
    -gravity center \
    -pointsize 10 -annotate +0+0 "Beszel\nAgent" \
    "$ICON_DIR/PACKAGE_ICON.PNG"

# Create 256x256 icon
convert -size 256x256 xc:lightblue \
    -gravity center \
    -pointsize 32 -annotate +0+0 "Beszel\nAgent" \
    "$ICON_DIR/PACKAGE_ICON_256.PNG"

echo "Placeholder icons created successfully."
echo "NOTE: Replace these with proper icons before production use."
