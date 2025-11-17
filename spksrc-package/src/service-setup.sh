#!/bin/bash

# Service setup for Beszel Agent
# Downloads architecture-specific binary during installation

set -e

SERVICE_LOG="${SYNOPKG_PKGDEST}/var/service-setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SERVICE_LOG"
}

service_postinst() {
    log "Starting Beszel Agent service setup..."

    # Create necessary directories
    mkdir -p "${SYNOPKG_PKGDEST}/bin"
    mkdir -p "${SYNOPKG_PKGDEST}/etc"
    mkdir -p "${SYNOPKG_PKGDEST}/var/lib"

    # Detect architecture and download binary
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            DOWNLOAD_ARCH="amd64"
            ;;
        aarch64)
            DOWNLOAD_ARCH="arm64"
            ;;
        armv7l|armv7)
            DOWNLOAD_ARCH="arm"
            ;;
        *)
            log "ERROR: Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    log "Architecture detected: $ARCH (downloading $DOWNLOAD_ARCH binary)"

    # Download Beszel agent binary
    DOWNLOAD_URL="https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_Linux_${DOWNLOAD_ARCH}.tar.gz"
    log "Downloading from: $DOWNLOAD_URL"

    if curl -sL "$DOWNLOAD_URL" | tar -xz -C "${SYNOPKG_PKGDEST}/bin/"; then
        log "Binary downloaded successfully"
    else
        log "ERROR: Failed to download binary"
        exit 1
    fi

    # Verify binary exists
    if [ ! -f "${SYNOPKG_PKGDEST}/bin/beszel-agent" ]; then
        log "ERROR: Binary not found after extraction"
        exit 1
    fi

    chmod +x "${SYNOPKG_PKGDEST}/bin/beszel-agent"

    # Create configuration from wizard inputs
    cat > "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf" << EOF
# Beszel Agent Configuration
# Generated on $(date)

export PORT="${wizard_port:-45876}"
export KEY="${wizard_ssh_key}"
export LISTEN="${wizard_port:-45876}"
EOF

    if [ -n "${wizard_extra_filesystems}" ]; then
        echo "export EXTRA_FILESYSTEMS=\"${wizard_extra_filesystems}\"" >> "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf"
        log "Extra filesystems configured: ${wizard_extra_filesystems}"
    fi

    chmod 600 "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf"
    chown ${SYNOPKG_PKGVAR}:${SYNOPKG_PKGVAR} "${SYNOPKG_PKGDEST}/etc/beszel-agent.conf"
    chown -R ${SYNOPKG_PKGVAR}:${SYNOPKG_PKGVAR} "${SYNOPKG_PKGDEST}/var"

    log "Service setup completed successfully"
}

service_postuninst() {
    # Cleanup
    log "Cleaning up after uninstall..."
    return 0
}

# Main
case "$1" in
    install)
        service_postinst
        ;;
    uninstall)
        service_postuninst
        ;;
esac

exit 0
