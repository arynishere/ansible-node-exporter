#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Set noninteractive mode to avoid prompts during package installation
export DEBIAN_FRONTEND=noninteractive

# Use apt if available, otherwise use apt-get
APT_COMMAND="apt"
if ! command -v $APT_COMMAND &> /dev/null; then
  APT_COMMAND="apt-get"
fi

echo "Updating package list..."
$APT_COMMAND update

# Check if update was successful
if [ $? -eq 0 ]; then
  echo "Package list update successful."
else
  echo "Package list update failed. Please check for errors."
  exit 1
fi

# Install necessary packages
$APT_COMMAND install -y wget tar

# Define variables
PROMETHEUS_VERSION="v1.7.0"
NODE_EXPORTER_VERSION="${PROMETHEUS_VERSION}"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_ARCHIVE="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_DIR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

# Download and install Node Exporter
echo "Downloading Node Exporter ${NODE_EXPORTER_VERSION}..."
wget "${NODE_EXPORTER_URL}"
tar xvf "${NODE_EXPORTER_ARCHIVE}"
cp "${NODE_EXPORTER_DIR}/node_exporter" /usr/local/bin

# Cleanup downloaded files
rm -f "${NODE_EXPORTER_ARCHIVE}"
rm -rf "${NODE_EXPORTER_DIR}"

# Create a dedicated user for Node Exporter
useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service for Node Exporter
tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Node Exporter
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

echo "Node Exporter ${NODE_EXPORTER_VERSION} has been installed and started successfully."
