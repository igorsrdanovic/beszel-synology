#!/bin/bash
# Create the absolute minimum SPK package that DSM should accept

set -e

BUILD_DIR="ultra_minimal_build"
OUTPUT_DIR="ultra_minimal_output"

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Minimal INFO - only absolutely required fields
cat > "$BUILD_DIR/INFO" << 'EOF'
package="test-minimal"
version="1.0.0"
displayname="Test Minimal"
description="Minimal test"
maintainer="Test"
arch="noarch"
os_min_ver="7.0"
startable="no"
thirdparty="yes"
admin_protocol="no"
admin_port="no"
EOF

# Empty package.tgz
mkdir -p "$BUILD_DIR/empty"
(cd "$BUILD_DIR/empty" && tar czf ../package.tgz .)
rm -rf "$BUILD_DIR/empty"

# Minimal icon - copy existing
cp icons/PACKAGE_ICON.PNG "$BUILD_DIR/"

# Create SPK without any ownership flags to test
(cd "$BUILD_DIR" && tar cf "../$OUTPUT_DIR/test-minimal.spk" \
    INFO \
    PACKAGE_ICON.PNG \
    package.tgz)

echo "Ultra-minimal package created: $OUTPUT_DIR/test-minimal.spk"
ls -lh "$OUTPUT_DIR/test-minimal.spk"
echo ""
echo "This package has NO scripts, NO conf files, NO wizard."
echo "If this fails, DSM has a fundamental issue with the tar format itself."
