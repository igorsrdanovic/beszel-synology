#!/bin/bash
# Synology Package Installation Diagnostic Script
# Run this ON YOUR SYNOLOGY NAS via SSH to diagnose installation issues

echo "===================================="
echo "Beszel Agent SPK Diagnostic"
echo "===================================="
echo ""

# Check if running on Synology
if [ ! -f /etc/synoinfo.conf ]; then
    echo "ERROR: This script must run on a Synology NAS"
    exit 1
fi

echo "DSM Version:"
cat /etc.defaults/VERSION
echo ""

echo "Architecture:"
uname -m
echo ""

echo "Checking recent package installation attempts..."
echo ""

echo "=== Last 20 lines of synopkg.log ==="
tail -20 /var/log/synopkg.log
echo ""

echo "=== Checking for beszel-agent specific logs ==="
if [ -f /var/log/packages/beszel-agent.log ]; then
    echo "Found beszel-agent.log:"
    cat /var/log/packages/beszel-agent.log
else
    echo "No beszel-agent.log found (package never started installation)"
fi
echo ""

echo "=== Package Center settings ==="
echo "Trust level setting:"
synowebapi --exec api=SYNO.Core.Package.Server method=get version=1 | grep -o '"trust_level":"[^"]*"' || echo "Unable to read trust level"
echo ""

echo "=== Testing tar on this system ==="
tar --version 2>&1 | head -3
echo ""

echo "=== Available volumes ==="
df -h | grep "/volume"
echo ""

echo "=== Disk space on /var/packages ==="
df -h /var/packages
echo ""

echo "===================================="
echo "Diagnostic complete"
echo "===================================="
echo ""
echo "Please share the output above, especially:"
echo "1. The synopkg.log entries"
echo "2. Any errors or warnings shown"
echo "3. The DSM version and architecture"
