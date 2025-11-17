#!/bin/bash
# Run this on your Synology NAS via SSH to get detailed error logs

echo "=== Checking for errors in synopkg.log ==="
grep -i "error\|fail\|invalid\|reject" /var/log/synopkg.log | tail -20

echo ""
echo "=== Checking packages.log ==="
tail -30 /var/log/packages.log 2>/dev/null || echo "packages.log not found"

echo ""
echo "=== Checking for beszel installation attempts ==="
grep -i "beszel" /var/log/synopkg.log | tail -20

echo ""
echo "=== Check Package Center database ==="
sqlite3 /var/packages/synopkg.db "SELECT * FROM task ORDER BY id DESC LIMIT 5;" 2>/dev/null || echo "Unable to query database"

echo ""
echo "=== System architecture and tar version ==="
uname -m
tar --version | head -1
