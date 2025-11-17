# Beszel Agent - Synology Package

A Synology SPK package for the [Beszel](https://beszel.dev) monitoring agent. This package allows you to easily install and run the Beszel agent on your Synology NAS to monitor system resources and Docker containers.

## Overview

**Beszel** is a lightweight server monitoring platform that consists of:
- **Beszel Hub**: Web application that displays monitoring data (runs on a separate server)
- **Beszel Agent**: Lightweight SSH server that collects and reports system metrics (this package)

This package installs the Beszel agent on your Synology NAS, allowing your Beszel hub to collect:
- CPU usage and temperature
- Memory usage
- Disk usage and I/O
- Network statistics
- Docker container metrics (optional)

## ⚠️ Important: DSM 7.2+ with Enhanced Security

**If you have DSM 7.2+ with enhanced security enabled**, you need a **Synology Developer Token** to install unsigned packages.

**Symptoms:**
- "Invalid file format" error
- "Unable to install because it runs with root privileges" error

**Solution:** See [DEVELOPER_TOKEN_REQUIRED.md](DEVELOPER_TOKEN_REQUIRED.md) for instructions on obtaining and installing the developer token.

**Alternative:** Use [Docker installation](#alternative-docker-installation) instead.

## Features

- ✅ Easy installation through DSM Package Center
- ✅ Interactive configuration wizard
- ✅ Automatic architecture detection (x86_64, ARM64, ARMv7)
- ✅ Runs as dedicated non-root user
- ✅ Optional Docker container monitoring
- ✅ Support for monitoring multiple filesystems
- ✅ Automatic service management
- ✅ Compatible with DSM 7.0+

## Requirements

- Synology NAS running DSM 7.0 or later
- A Beszel hub server (running elsewhere)
- SSH public key from your Beszel hub
- Network connectivity between NAS and hub

## Installation

### 1. Download the Package

Download the latest `.spk` file from the [releases page](../../releases).

### 2. Install via Package Center

1. Open **Package Center** on your Synology DSM
2. Click **Manual Install**
3. Browse and select the downloaded `.spk` file
4. Click **Next** and follow the installation wizard

### 3. Configuration Wizard

During installation, you'll be prompted for:

#### Step 1: Basic Configuration
- **SSH Public Key**: The public key from your Beszel hub (starts with `ssh-ed25519`)
  - Get this from your Beszel hub settings
  - Format: `ssh-ed25519 AAAA...`
- **Port**: Port for the agent to listen on (default: 45876)
  - Make sure this port is not blocked by firewall
  - You'll need this when adding the system to your hub

#### Step 2: Advanced Options
- **Monitor Docker**: Enable Docker container monitoring (requires Docker package)
- **Extra Filesystems**: Additional mount points to monitor (e.g., `/volume1,/volume2`)

### 4. Configure Your Beszel Hub

After installation:

1. Note your Synology NAS IP address
2. Go to your Beszel hub web interface
3. Add a new system with:
   - **Host**: Your NAS IP address
   - **Port**: The port you configured (default: 45876)
   - **Name**: A friendly name for your NAS

The hub will connect to the agent using SSH key authentication.

## Building from Source

This repository provides **two build methods**:

1. **Manual Build Script** (quick and simple)
2. **spksrc Framework Build** (official SynoCommunity framework)

### Method 1: Manual Build Script (Recommended for Quick Builds)

#### Prerequisites

- Linux or macOS environment
- `tar` command
- Basic shell environment

#### Build Steps

```bash
# Clone the repository
git clone https://github.com/yourusername/beszel-synology.git
cd beszel-synology

# Build the package
./build.sh
```

The SPK file will be created in the `output/` directory as `beszel-agent-0.10.2.spk`.

### Method 2: spksrc Framework Build (Recommended for Contributing)

For building with the official SynoCommunity spksrc framework, see the detailed guide in [`spksrc-package/README.md`](spksrc-package/README.md).

#### Quick Start

```bash
# Clone spksrc
git clone https://github.com/SynoCommunity/spksrc.git
cd spksrc
make setup

# Copy package files
cp -r /path/to/beszel-synology/spksrc-package/* spk/beszel-agent/

# Build
make -C spk/beszel-agent
```

Built package will be in `spksrc/packages/beszel-agent-0.10.2-1-noarch.spk`.

### Project Structure

```
beszel-synology/
├── source/beszel-agent/       # Manual build package files
│   ├── INFO                   # Package metadata
│   ├── scripts/               # Installation & control scripts
│   │   ├── preinst           # Pre-installation checks
│   │   ├── postinst          # Post-installation setup
│   │   ├── preuninst         # Pre-uninstall cleanup
│   │   ├── postuninst        # Post-uninstall cleanup
│   │   └── start-stop-status # Service control script
│   ├── conf/                  # Package configuration
│   │   ├── privilege         # Permission settings
│   │   ├── resource          # Resource definitions
│   │   └── protocol          # Port configuration
│   ├── WIZARD_UIFILES/       # Installation wizard
│   │   └── install_uifile    # Wizard configuration (JSON)
│   └── ui/                    # Package UI files
│       └── config            # Configuration page
├── spksrc-package/            # spksrc framework build files
│   ├── Makefile              # spksrc package definition
│   ├── src/
│   │   ├── service-setup.sh  # Service setup script
│   │   ├── beszel-agent.sh   # Service control script
│   │   ├── wizard/           # Installation wizard
│   │   ├── conf/             # Configuration files
│   │   └── beszel-agent.png  # Package icon
│   └── README.md             # spksrc build documentation
├── icons/                     # Package icons (shared)
│   ├── PACKAGE_ICON.PNG      # 72x72 icon
│   └── PACKAGE_ICON_256.PNG  # 256x256 icon
├── build.sh                   # Manual build script
├── create_simple_icons.py     # Icon generation script
└── README.md                  # This file
```

## Configuration

### Runtime Configuration

The agent configuration is stored in:
```
/var/packages/beszel-agent/target/etc/beszel-agent.conf
```

You can manually edit this file and restart the service:

```bash
# Edit configuration (via SSH as root)
sudo vi /var/packages/beszel-agent/target/etc/beszel-agent.conf

# Restart the service
sudo /var/packages/beszel-agent/scripts/start-stop-status restart
```

### Environment Variables

The configuration file supports these environment variables:

- `PORT` or `LISTEN`: Port number (default: 45876)
- `KEY`: SSH public key from Beszel hub (required)
- `FILESYSTEM`: Primary filesystem to monitor (auto-detected)
- `EXTRA_FILESYSTEMS`: Additional filesystems (comma-separated)

### Logs

View agent logs at:
```
/var/packages/beszel-agent/target/var/beszel-agent.log
```

Or use the service script:
```bash
/var/packages/beszel-agent/scripts/start-stop-status log
```

## Troubleshooting

### Agent Won't Start

1. Check the log file:
   ```bash
   cat /var/packages/beszel-agent/target/var/beszel-agent.log
   ```

2. Verify the binary exists:
   ```bash
   ls -l /var/packages/beszel-agent/target/bin/beszel-agent
   ```

3. Check configuration:
   ```bash
   cat /var/packages/beszel-agent/target/etc/beszel-agent.conf
   ```

### Hub Can't Connect

1. Verify the agent is running:
   ```bash
   /var/packages/beszel-agent/scripts/start-stop-status status
   ```

2. Check if the port is listening:
   ```bash
   netstat -tuln | grep 45876
   ```

3. Verify firewall settings allow incoming connections on the configured port

4. Ensure the SSH key in the configuration matches your hub's key

### Docker Monitoring Not Working

1. Verify Docker package is installed
2. Check if beszel user is in docker group:
   ```bash
   groups beszel
   ```

3. If not, add manually:
   ```bash
   sudo synogroup --member docker beszel
   sudo /var/packages/beszel-agent/scripts/start-stop-status restart
   ```

### Port Already in Use

If installation fails due to port conflict:

1. Choose a different port during installation, or
2. Stop the service using the conflicting port

## Alternative: Docker Installation

If you cannot install the SPK package (e.g., enhanced security without developer token), you can run Beszel Agent via Docker:

```bash
# SSH into your Synology NAS, then run:
docker run -d \
  --name beszel-agent \
  --restart unless-stopped \
  -p 45876:45876 \
  -v /:/host:ro \
  -e KEY="ssh-ed25519 AAAA...your-public-key-here" \
  -e PORT=45876 \
  henrygd/beszel-agent
```

**Advantages:**
- No developer token required
- Works on all DSM versions with Docker support
- Easy updates (`docker pull henrygd/beszel-agent`)

**Optional: Docker Monitoring**

To monitor Docker containers, add:
```bash
-v /var/run/docker.sock:/var/run/docker.sock:ro
```

**Optional: Custom Filesystems**

To monitor specific filesystems:
```bash
-e EXTRA_FILESYSTEMS="/volume1,/volume2"
```

## Uninstallation

### SPK Package

1. Open **Package Center**
2. Select **Beszel Agent**
3. Click **Uninstall**

The package will:
- Stop the agent service
- Remove all package files
- Keep the `beszel` user (can be manually removed if needed)

### Docker

```bash
docker stop beszel-agent
docker rm beszel-agent
```

## Security Considerations

- The agent runs as a non-root user (`beszel`)
- SSH key authentication only (no password)
- Consider using a firewall to restrict access to the agent port
- Only expose the agent port to trusted networks (use VPN if accessing remotely)
- Configuration file has restricted permissions (600)

## Limitations

### DSM Systemd Constraints

Synology DSM 7.x uses systemd version 219, which doesn't support newer directives. This package uses a simple service wrapper instead.

### Architecture Support

The package automatically downloads the correct binary for:
- x86_64 (Intel/AMD)
- ARM64 (AArch64)
- ARMv7

Other architectures are not currently supported.

## Development

### Testing

Before releasing:

1. Test installation on DSM 7.x
2. Verify agent starts and connects to hub
3. Check metrics are reported correctly
4. Test Docker monitoring (if applicable)
5. Verify service survives reboot
6. Test uninstallation

### Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on actual Synology hardware
5. Submit a pull request

## Resources

- **Beszel Project**: https://github.com/henrygd/beszel
- **Beszel Documentation**: https://beszel.dev
- **Synology Developer Guide**: https://help.synology.com/developer-guide/
- **Issue Tracker**: [GitHub Issues](../../issues)

## License

This package wrapper is provided as-is for the Beszel project. The Beszel agent itself is licensed under its own terms (see the [Beszel repository](https://github.com/henrygd/beszel)).

## Version History

### 0.10.2 (Initial Release)
- Initial Synology package implementation
- Support for DSM 7.0+
- Interactive installation wizard
- Docker monitoring support
- Multi-filesystem monitoring
- Automatic architecture detection

## Support

For issues specific to this Synology package, please open an issue on this repository.

For Beszel-related questions, refer to the [Beszel documentation](https://beszel.dev) or [Beszel GitHub](https://github.com/henrygd/beszel).
