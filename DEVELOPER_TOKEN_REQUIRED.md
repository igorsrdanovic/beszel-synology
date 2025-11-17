# Installing on DSM 7.2+ with Enhanced Security

## Problem

If you get errors like:
- "Invalid file format"
- "Unable to install because it runs with root privileges"

**Your DSM likely has enhanced security enabled** (`support_fw_security="yes"`), which requires packages to be **digitally signed by Synology** or installed with a **developer token**.

## Solution: Install Synology Developer Token

### Step 1: Get the Developer Token

1. Go to: https://www.synology.com/en-us/support/developer#tool
2. Sign in with your Synology account
3. Download the **Developer Certificate/Token**

### Step 2: Install the Token on Your NAS

SSH into your Synology NAS and install the token:

```bash
# Upload the token SPK to your NAS, then:
sudo synopkg install /path/to/synology-developer-token.spk
```

Or via Package Center:
1. Open Package Center
2. Manual Install
3. Select the developer token SPK file
4. Install it

### Step 3: Install Beszel Agent

Now you can install the Beszel Agent package:

```bash
# Via Package Center:
1. Package Center → Manual Install
2. Select beszel-agent-0.10.2.spk
3. Follow the installation wizard
```

## Why This is Needed

DSM 7.2+ with enhanced security (`support_fw_security="yes"`) implements strict package signing requirements:

- **Signed packages**: Install without restriction
- **Unsigned packages**: Blocked unless developer token is installed

The developer token tells DSM to allow installation of unsigned third-party packages for development/testing purposes.

## Alternative: Docker Installation

If you cannot or don't want to install the developer token, you can run Beszel Agent via Docker instead:

```bash
docker run -d \
  --name beszel-agent \
  --restart unless-stopped \
  -p 45876:45876 \
  -v /:/host:ro \
  -e KEY="your-ssh-ed25519-public-key-here" \
  henrygd/beszel-agent
```

## Check if You Need the Token

SSH into your NAS and check:

```bash
cat /etc/synoinfo.conf | grep support_fw_security
```

If it returns `support_fw_security="yes"`, you need the developer token to install unsigned SPK packages.

## References

- [Synology Developer Tools](https://www.synology.com/en-us/support/developer#tool)
- [DSM Developer Guide 7 (PDF)](https://global.download.synology.com/download/Document/Software/DeveloperGuide/Os/DSM/All/enu/DSM_Developer_Guide_7_enu.pdf)
- [Privilege Documentation](https://help.synology.com/developer-guide/privilege/)
