#!/bin/bash

# Beszel Agent service control script for spksrc
# This script is called by the spksrc framework to start/stop the service

# Load configuration
if [ -f "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf" ]; then
    source "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf"
fi

# Export environment variables for the agent
export PORT
export KEY
export LISTEN
export EXTRA_FILESYSTEMS
export FILESYSTEM

PID_FILE="${SYNOPKG_PKGDEST}/var/beszel-agent.pid"
LOG_FILE="${SYNOPKG_PKGDEST}/var/beszel-agent.log"

case "$1" in
    start)
        # Start agent
        cd "${SYNOPKG_PKGDEST}"
        nohup "${SYNOPKG_PKGDEST}/bin/beszel-agent" >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        ;;
    stop)
        # Stop agent gracefully
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            if kill -0 "$PID" 2>/dev/null; then
                kill "$PID" 2>/dev/null || true
                # Wait for graceful shutdown
                for i in $(seq 1 10); do
                    if ! kill -0 "$PID" 2>/dev/null; then
                        break
                    fi
                    sleep 1
                done
                # Force kill if still running
                kill -9 "$PID" 2>/dev/null || true
            fi
            rm -f "$PID_FILE"
        fi
        ;;
    status)
        # Check if running
        if [ -f "$PID_FILE" ]; then
            if kill -0 $(cat "$PID_FILE") 2>/dev/null; then
                exit 0
            fi
        fi
        exit 1
        ;;
    log)
        # Show log
        if [ -f "$LOG_FILE" ]; then
            tail -n 50 "$LOG_FILE"
        else
            echo "No log file found"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status|log}"
        exit 1
        ;;
esac

exit 0
