#!/bin/bash

# Installation wizard for Beszel Agent
# Generates JSON configuration for DSM installation wizard

cat << 'EOF'
[
  {
    "step_title": "Beszel Hub Configuration",
    "items": [
      {
        "type": "textfield",
        "desc": "Enter the SSH public key from your Beszel hub. You can get this from the 'Add System' dialog in your Beszel hub web interface. The key should start with 'ssh-ed25519'.",
        "subitems": [
          {
            "key": "wizard_ssh_key",
            "desc": "SSH Public Key (ssh-ed25519 ...)",
            "validator": {
              "allowBlank": false,
              "regex": {
                "expr": "^ssh-ed25519\\s+[A-Za-z0-9+/]+[=]{0,3}(\\s+.*)?$",
                "errorText": "Invalid SSH key format. Must be an ssh-ed25519 public key."
              }
            }
          }
        ]
      },
      {
        "type": "textfield",
        "desc": "Port for the agent to listen on. Default is 45876. Make sure this port is not blocked by your firewall.",
        "subitems": [
          {
            "key": "wizard_port",
            "desc": "Port",
            "defaultValue": "45876",
            "validator": {
              "allowBlank": false,
              "regex": {
                "expr": "^[0-9]{1,5}$",
                "errorText": "Port must be a number between 1 and 65535."
              }
            }
          }
        ]
      },
      {
        "type": "textfield",
        "desc": "Optional: Additional filesystems to monitor (comma-separated mount points, e.g., /volume1,/volume2). Leave blank to use defaults.",
        "subitems": [
          {
            "key": "wizard_extra_filesystems",
            "desc": "Extra Filesystems (optional)",
            "defaultValue": "",
            "validator": {
              "allowBlank": true
            }
          }
        ]
      }
    ]
  },
  {
    "step_title": "Installation Complete",
    "items": [
      {
        "desc": "Beszel Agent has been installed successfully. After clicking 'Apply', the agent will start automatically.<br><br><b>Next steps:</b><br>1. Go to your Beszel hub web interface<br>2. Add this system using the IP address of your NAS and the port you configured<br>3. The agent will connect automatically using the SSH key you provided<br><br><b>Note:</b> You can view logs at /var/packages/beszel-agent/target/var/beszel-agent.log"
      }
    ]
  }
]
EOF
