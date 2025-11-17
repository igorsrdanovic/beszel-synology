# Building Beszel Agent with SynoCommunity spksrc

This directory contains a spksrc-compatible package structure for building the Beszel Agent using the [SynoCommunity spksrc framework](https://github.com/SynoCommunity/spksrc).

## Overview

The spksrc framework is the official build system used by the SynoCommunity project to create Synology packages. Using spksrc provides:

- Consistent package structure following Synology best practices
- Automatic handling of privileges and user creation
- Support for multiple architectures
- Integration with Synology's package framework

## Prerequisites

1. **Linux environment** (native or WSL/VM)
2. **spksrc framework** cloned locally
3. **Build dependencies** (installed via spksrc setup)

## Build Instructions

### Step 1: Clone and Setup spksrc

```bash
# Clone the spksrc repository
git clone https://github.com/SynoCommunity/spksrc.git
cd spksrc

# Install build dependencies
make setup
```

### Step 2: Copy Package Files

Copy the contents of this directory into the spksrc framework:

```bash
# From the beszel-synology repository root
cp -r spksrc-package/* /path/to/spksrc/spk/beszel-agent/
```

### Step 3: Build the Package

```bash
# From the spksrc root directory
cd /path/to/spksrc

# Build for all supported architectures
make -C spk/beszel-agent

# Or build for a specific architecture
# make -C spk/beszel-agent ARCH-x86_64
```

### Step 4: Locate Built Package

The built SPK file will be in:
```
spksrc/packages/beszel-agent-0.10.2-1-noarch.spk
```

## Package Structure

### Files Included

- `Makefile` - Package metadata and build configuration
- `src/service-setup.sh` - Post-installation setup (downloads binary)
- `src/beszel-agent.sh` - Service start/stop script
- `src/wizard/install_uifile.sh` - Installation wizard configuration
- `src/conf/privilege` - Privilege configuration
- `src/beszel-agent.png` - Package icon (72x72 PNG)

### How It Works

1. **Installation Wizard**: Collects SSH key, port, and optional filesystem configuration
2. **Service Setup**: Downloads architecture-specific binary from GitHub releases
3. **User Creation**: Automatically creates `beszel-agent` user (via `SERVICE_USER = auto`)
4. **Service Management**: Uses spksrc's service framework for start/stop/status

### Architecture Detection

The package is marked as `noarch` but downloads the correct binary during installation:

- **x86_64** → Downloads `beszel-agent_Linux_amd64.tar.gz`
- **aarch64** → Downloads `beszel-agent_Linux_arm64.tar.gz`
- **armv7l** → Downloads `beszel-agent_Linux_arm.tar.gz`

## Configuration

### Package Metadata (Makefile)

Key settings in the Makefile:

```makefile
SPK_NAME = beszel-agent          # Package identifier
SPK_VERS = 0.10.2                # Package version
SERVICE_USER = auto              # Auto-create dedicated user
SERVICE_PORT = 45876             # Default agent port
ARCH = noarch                    # Universal package
```

### Runtime Configuration

After installation, configuration is stored in:
```
/var/packages/beszel-agent/target/etc/beszel-agent.conf
```

Environment variables set:
- `PORT` - Agent listening port
- `KEY` - SSH public key from Beszel hub
- `LISTEN` - Same as PORT
- `EXTRA_FILESYSTEMS` - Optional additional filesystems

## Testing

After building:

1. Copy the SPK to your computer
2. Open Synology DSM Package Center
3. Click "Manual Install"
4. Upload the built SPK file
5. Follow the installation wizard
6. Verify the agent starts and connects to your Beszel hub

## Troubleshooting

### Build Fails

```bash
# Clean and rebuild
make -C spk/beszel-agent clean
make -C spk/beszel-agent

# Check spksrc dependencies
make setup
```

### Binary Download Fails

Check the logs:
```bash
cat /var/packages/beszel-agent/target/var/service-setup.log
```

### Service Won't Start

Check service status and logs:
```bash
# Via DSM Package Center or SSH
/var/packages/beszel-agent/scripts/start-stop-status status
/var/packages/beszel-agent/scripts/start-stop-status log
```

## Differences from Manual Build

This spksrc build differs from the manual build (`build.sh`) in:

| Feature | Manual Build | spksrc Build |
|---------|-------------|--------------|
| Build method | Shell script | Makefile + framework |
| User creation | Custom script | Framework auto |
| Privilege handling | Manual config | Framework managed |
| Service management | Custom script | Framework provided |
| Updates | Manual | Framework update system |

Both methods produce valid SPK files that work on Synology NAS.

## Contributing to SynoCommunity

If you want to contribute this package to the official SynoCommunity repository:

1. Fork the spksrc repository
2. Add this package to `spk/beszel-agent/`
3. Test thoroughly on multiple architectures
4. Submit a pull request
5. Follow SynoCommunity contribution guidelines

## Support

- **Beszel Project**: https://github.com/henrygd/beszel
- **Beszel Documentation**: https://beszel.dev
- **SynoCommunity spksrc**: https://github.com/SynoCommunity/spksrc
- **Issues**: Report issues specific to this package in the beszel-synology repository

## License

This package wrapper is provided under the MIT License. The Beszel agent itself is licensed separately under its own terms.
