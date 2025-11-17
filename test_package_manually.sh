#!/bin/bash
# Run this script ON YOUR SYNOLOGY NAS to manually test package extraction
# This helps identify what DSM doesn't like about the package

echo "=== Manual Package Test on Synology NAS ==="
echo ""

if [ ! -f beszel-agent-0.10.2.spk ]; then
    echo "ERROR: beszel-agent-0.10.2.spk not found in current directory"
    echo "Please upload the SPK file to the same directory as this script"
    exit 1
fi

echo "1. Testing tar extraction..."
if tar tf beszel-agent-0.10.2.spk > /dev/null 2>&1; then
    echo "✓ SPK can be listed with tar"
else
    echo "✗ FAIL: Cannot list SPK contents"
    exit 1
fi

echo ""
echo "2. Extracting SPK..."
rm -rf /tmp/spk_test
mkdir -p /tmp/spk_test
cd /tmp/spk_test
tar xf ~/beszel-agent-0.10.2.spk 2>&1

echo ""
echo "3. Checking extracted files..."
ls -la

echo ""
echo "4. Validating INFO file..."
if [ -f INFO ]; then
    echo "✓ INFO file exists"
    cat INFO
else
    echo "✗ INFO file missing"
fi

echo ""
echo "5. Testing package.tgz..."
if [ -f package.tgz ]; then
    echo "✓ package.tgz exists"
    if tar tzf package.tgz > /dev/null 2>&1; then
        echo "✓ package.tgz can be extracted"
        echo "Contents:"
        tar tzf package.tgz | head -10
    else
        echo "✗ package.tgz is corrupted"
    fi
else
    echo "✗ package.tgz missing"
fi

echo ""
echo "6. Validating JSON files..."
for json_file in conf/privilege conf/resource WIZARD_UIFILES/install_uifile; do
    if [ -f "$json_file" ]; then
        echo "Checking $json_file..."
        if python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "✓ $json_file is valid JSON"
        else
            echo "✗ $json_file has invalid JSON"
            cat "$json_file"
        fi
    fi
done

echo ""
echo "7. Checking script syntax..."
for script in scripts/*; do
    if [ -f "$script" ]; then
        echo "Checking $script..."
        if bash -n "$script" 2>&1; then
            echo "✓ $script has valid syntax"
        else
            echo "✗ $script has syntax errors"
        fi
    fi
done

echo ""
echo "=== Test Complete ==="
echo "If all tests passed, the package structure is valid."
echo "The issue may be with DSM's security policy or privilege requirements."
