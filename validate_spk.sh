#!/bin/bash
# SPK Package Validation Script
# Checks if the SPK package meets Synology requirements

set -e

SPK_FILE="${1:-output/beszel-agent-0.10.2.spk}"

if [ ! -f "$SPK_FILE" ]; then
    echo "Error: SPK file not found: $SPK_FILE"
    exit 1
fi

echo "===================================="
echo "Synology SPK Validation"
echo "===================================="
echo "Package: $SPK_FILE"
echo ""

# Test 1: Check file type
echo "[1] Checking file type..."
FILE_TYPE=$(file "$SPK_FILE")
if echo "$FILE_TYPE" | grep -q "tar archive"; then
    echo "✓ PASS: Valid tar archive"
else
    echo "✗ FAIL: Not a valid tar archive"
    echo "  Got: $FILE_TYPE"
    exit 1
fi

# Test 2: Check if SPK is uncompressed
if echo "$FILE_TYPE" | grep -q "gzip\|bzip2\|xz"; then
    echo "✗ FAIL: SPK must be uncompressed tar (not gzip/bzip2)"
    exit 1
else
    echo "✓ PASS: SPK is uncompressed tar"
fi

# Test 3: Check required files exist
echo ""
echo "[2] Checking required files..."
REQUIRED_FILES=("INFO" "PACKAGE_ICON.PNG" "package.tgz" "scripts" "conf")
for req_file in "${REQUIRED_FILES[@]}"; do
    if tar tf "$SPK_FILE" | grep -q "^${req_file}"; then
        echo "✓ PASS: $req_file exists"
    else
        echo "✗ FAIL: Missing required file: $req_file"
        exit 1
    fi
done

# Test 4: Check INFO file content
echo ""
echo "[3] Checking INFO file..."
tar xOf "$SPK_FILE" INFO > /tmp/spk_info_check.txt

REQUIRED_FIELDS=("package" "version" "displayname" "arch" "maintainer")
for field in "${REQUIRED_FIELDS[@]}"; do
    if grep -q "^${field}=" /tmp/spk_info_check.txt; then
        value=$(grep "^${field}=" /tmp/spk_info_check.txt | cut -d'=' -f2-)
        echo "✓ PASS: $field = $value"
    else
        echo "✗ FAIL: Missing required field: $field"
        exit 1
    fi
done

# Test 5: Check package.tgz is gzip compressed
echo ""
echo "[4] Checking package.tgz..."
PACKAGE_TGZ_TYPE=$(tar xOf "$SPK_FILE" package.tgz | file -)
if echo "$PACKAGE_TGZ_TYPE" | grep -q "gzip"; then
    echo "✓ PASS: package.tgz is gzip compressed"
else
    echo "✗ FAIL: package.tgz must be gzip compressed"
    echo "  Got: $PACKAGE_TGZ_TYPE"
    exit 1
fi

# Test 6: Check package.tgz structure
echo ""
echo "[5] Checking package.tgz structure..."
tar xOf "$SPK_FILE" package.tgz | tar tzf - > /tmp/package_contents.txt
echo "Package contents:"
cat /tmp/package_contents.txt | head -20

# Check for unwanted nested directories
if grep -q "^package/" /tmp/package_contents.txt; then
    echo "✗ WARNING: Found 'package/' directory in package.tgz (should be flat)"
fi

# Test 7: Check scripts are executable
echo ""
echo "[6] Checking script permissions..."
tar tvf "$SPK_FILE" scripts/ | while read -r perm rest; do
    if [[ "$perm" == *"x"* ]]; then
        echo "✓ PASS: Scripts have execute permission"
        break
    else
        echo "✗ FAIL: Scripts missing execute permission"
        exit 1
    fi
done

# Test 8: Check icon file sizes
echo ""
echo "[7] Checking icon files..."
ICON_SIZE=$(tar xOf "$SPK_FILE" PACKAGE_ICON.PNG | wc -c)
ICON256_SIZE=$(tar xOf "$SPK_FILE" PACKAGE_ICON_256.PNG | wc -c)

if [ "$ICON_SIZE" -lt 100 ]; then
    echo "✗ WARNING: PACKAGE_ICON.PNG too small ($ICON_SIZE bytes)"
else
    echo "✓ PASS: PACKAGE_ICON.PNG size: $ICON_SIZE bytes"
fi

if [ "$ICON256_SIZE" -lt 100 ]; then
    echo "✗ WARNING: PACKAGE_ICON_256.PNG too small ($ICON256_SIZE bytes)"
else
    echo "✓ PASS: PACKAGE_ICON_256.PNG size: $ICON256_SIZE bytes"
fi

# Test 9: Verify icons are valid PNG
if tar xOf "$SPK_FILE" PACKAGE_ICON.PNG | file - | grep -q "PNG"; then
    echo "✓ PASS: PACKAGE_ICON.PNG is valid PNG"
else
    echo "✗ FAIL: PACKAGE_ICON.PNG is not a valid PNG"
fi

if tar xOf "$SPK_FILE" PACKAGE_ICON_256.PNG | file - | grep -q "PNG"; then
    echo "✓ PASS: PACKAGE_ICON_256.PNG is valid PNG"
else
    echo "✗ FAIL: PACKAGE_ICON_256.PNG is not a valid PNG"
fi

# Test 10: Check JSON wizard file
echo ""
echo "[8] Checking wizard JSON..."
if tar tf "$SPK_FILE" | grep -q "WIZARD_UIFILES"; then
    tar xOf "$SPK_FILE" WIZARD_UIFILES/install_uifile > /tmp/wizard_check.json
    if python3 -c "import json; json.load(open('/tmp/wizard_check.json'))" 2>/dev/null; then
        echo "✓ PASS: Wizard JSON is valid"
    else
        echo "✗ FAIL: Wizard JSON is invalid"
        echo "JSON content:"
        cat /tmp/wizard_check.json
        exit 1
    fi
fi

# Summary
echo ""
echo "===================================="
echo "Validation Summary"
echo "===================================="
echo "✓ Package structure appears valid"
echo ""
echo "Package size: $(du -h "$SPK_FILE" | cut -f1)"
echo ""
echo "If installation still fails on Synology, check:"
echo "1. DSM version compatibility (requires DSM 7.0+)"
echo "2. Synology Package Center logs at /var/log/packages/"
echo "3. Enable 'Install package from any publisher' in Package Center settings"
echo ""

# Cleanup
rm -f /tmp/spk_info_check.txt /tmp/package_contents.txt /tmp/wizard_check.json

exit 0
