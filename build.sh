#!/bin/bash
# Build script for Beszel Agent Synology Package
# Creates the SPK package file

set -e

# Configuration
PACKAGE_NAME="beszel-agent"
PACKAGE_VERSION="0.10.2"
SOURCE_DIR="source/beszel-agent"
BUILD_DIR="build"
OUTPUT_DIR="output"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Clean previous build
log_info "Cleaning previous build..."
rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    log_error "Source directory not found: $SOURCE_DIR"
    exit 1
fi

log_info "Building Beszel Agent package v${PACKAGE_VERSION}..."

# Create package directory structure in build
PACKAGE_DIR="$BUILD_DIR/package"
mkdir -p "$PACKAGE_DIR/bin"
mkdir -p "$PACKAGE_DIR/etc"
mkdir -p "$PACKAGE_DIR/var/lib"
mkdir -p "$PACKAGE_DIR/ui"

log_info "Creating package directory structure..."

# Copy UI files
if [ -d "$SOURCE_DIR/ui" ]; then
    cp -r "$SOURCE_DIR/ui/"* "$PACKAGE_DIR/ui/" || log_warn "No UI files found"
fi

# Create package.tgz
log_info "Creating package.tgz..."
(cd "$BUILD_DIR" && tar czf package.tgz package/)

# Copy package metadata files to build directory
log_info "Copying package metadata..."
cp "$SOURCE_DIR/INFO" "$BUILD_DIR/"

# Copy icons
log_info "Copying package icons..."
cp icons/PACKAGE_ICON.PNG "$BUILD_DIR/"
cp icons/PACKAGE_ICON_256.PNG "$BUILD_DIR/"

# Copy scripts
log_info "Copying installation scripts..."
mkdir -p "$BUILD_DIR/scripts"
cp "$SOURCE_DIR/scripts/"* "$BUILD_DIR/scripts/"

# Make scripts executable
chmod 755 "$BUILD_DIR/scripts/"*

# Copy configuration files
log_info "Copying configuration files..."
mkdir -p "$BUILD_DIR/conf"
cp "$SOURCE_DIR/conf/"* "$BUILD_DIR/conf/"

# Copy wizard UI files
log_info "Copying wizard UI files..."
mkdir -p "$BUILD_DIR/WIZARD_UIFILES"
cp "$SOURCE_DIR/WIZARD_UIFILES/"* "$BUILD_DIR/WIZARD_UIFILES/"

# Create the SPK package
SPK_FILE="$OUTPUT_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}.spk"
log_info "Creating SPK package: $(basename $SPK_FILE)..."

(cd "$BUILD_DIR" && tar cf "../$SPK_FILE" \
    INFO \
    PACKAGE_ICON.PNG \
    PACKAGE_ICON_256.PNG \
    package.tgz \
    scripts/ \
    conf/ \
    WIZARD_UIFILES/)

# Verify the package was created
if [ -f "$SPK_FILE" ]; then
    SIZE=$(du -h "$SPK_FILE" | cut -f1)
    log_info "Package created successfully: $SPK_FILE (${SIZE})"

    log_info "Package contents:"
    tar tf "$SPK_FILE" | head -20

    log_info ""
    log_info "=================================="
    log_info "Build completed successfully!"
    log_info "=================================="
    log_info "Package: $SPK_FILE"
    log_info "Version: $PACKAGE_VERSION"
    log_info "Size: $SIZE"
    log_info ""
    log_warn "IMPORTANT: Replace placeholder icons in icons/ directory before production use"
    log_info ""
    log_info "Installation instructions:"
    log_info "1. Open Synology DSM Package Center"
    log_info "2. Click 'Manual Install'"
    log_info "3. Upload the SPK file: $SPK_FILE"
    log_info "4. Follow the installation wizard"
else
    log_error "Failed to create package"
    exit 1
fi
