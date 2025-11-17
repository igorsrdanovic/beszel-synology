SPK_NAME = beszel-agent
SPK_VERS = 0.10.2
SPK_REV = 1
SPK_ICON = src/beszel-agent.png

MAINTAINER = Igor Srdanovic
DESCRIPTION = Lightweight monitoring agent that reports system metrics to Beszel hub server. Supports CPU, memory, disk, network, and Docker container monitoring.
DISPLAY_NAME = Beszel Agent
CHANGELOG = "Initial release: Beszel monitoring agent for Synology NAS"

HOMEPAGE = https://beszel.dev
LICENSE = MIT

STARTABLE = yes
SERVICE_USER = auto
SERVICE_SETUP = src/service-setup.sh
SERVICE_PORT = 45876
SERVICE_PORT_TITLE = Agent Port

SPK_COMMANDS = bin/beszel-agent

# Use noarch and download binary at install time
ARCH = noarch

CONF_DIR = src/conf

WIZARDS_DIR = src/wizard

PLIST_TRANSFORM = sed -e 's|@DISPLAY_NAME@|$(DISPLAY_NAME)|g'

include ../../mk/spksrc.spk.mk
