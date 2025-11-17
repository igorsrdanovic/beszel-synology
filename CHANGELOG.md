# Changelog

All notable changes to the Beszel Agent Synology Package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.2] - 2024-11-17

### Added
- Initial release of Beszel Agent Synology Package
- Support for DSM 7.0 and later
- Interactive installation wizard with configuration options
- Automatic architecture detection (x86_64, ARM64, ARMv7)
- Automatic binary download from Beszel releases
- Service management scripts (start, stop, status, restart)
- Pre-installation validation (port availability, SSH key format)
- Post-installation setup (user creation, permissions, configuration)
- Docker container monitoring support (optional)
- Multi-filesystem monitoring support
- Comprehensive logging system
- Build script for creating SPK packages
- Complete documentation (README, installation guide, troubleshooting)

### Security
- Agent runs as dedicated non-root user (`beszel`)
- SSH key-based authentication only
- Restricted file permissions on configuration files (600)
- Optional Docker socket access with proper group membership

### Infrastructure
- Complete SPK package structure
- Installation wizard UI
- Package metadata and icons
- Build automation script
- Git repository setup with .gitignore

## [Unreleased]

### Planned Features
- Web UI for post-installation configuration
- Automatic update mechanism
- Log viewer in DSM interface
- Integration with DSM notification system
- Support for multiple Beszel hubs
- Enhanced error reporting and diagnostics

---

For more details on each release, see the [releases page](../../releases).
