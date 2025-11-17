#!/bin/bash
# Build a minimal test SPK to isolate the "Invalid file format" issue

set -e

BUILD_DIR="test_build"
OUTPUT_DIR="test_output"

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Create minimal INFO file
cat > "$BUILD_DIR/INFO" << 'EOF'
package="beszel-test"
version="0.0.1"
displayname="Beszel Test"
description="Minimal test package"
maintainer="Test"
arch="noarch"
os_min_ver="7.0-40000"
startable="no"
EOF

# Create minimal package.tgz with a simple test file
mkdir -p "$BUILD_DIR/package"
echo "test" > "$BUILD_DIR/package/test.txt"
(cd "$BUILD_DIR/package" && tar czf ../package.tgz .)
rm -rf "$BUILD_DIR/package"

# Create minimal icon (use existing one)
cp icons/PACKAGE_ICON.PNG "$BUILD_DIR/"

# Detect tar for ownership
if tar --version 2>&1 | grep -q "bsdtar"; then
    TAR_OPTS="--uid 0 --gid 0"
else
    TAR_OPTS="--owner=0 --group=0"
fi

# Create SPK
(cd "$BUILD_DIR" && tar $TAR_OPTS -cf "../$OUTPUT_DIR/beszel-test.spk" \
    INFO \
    PACKAGE_ICON.PNG \
    package.tgz)

echo "Minimal test package created: $OUTPUT_DIR/beszel-test.spk"
echo ""
echo "Try installing this minimal package on your NAS."
echo "If it installs: The issue is with our package configuration"
echo "If it fails: The issue is with DSM's package format requirements"
