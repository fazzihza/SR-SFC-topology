#!/bin/sh

echo "PC1 Init Script (Kubernetes/Clabernetes): Configuring IP and Installing Node Exporter"

# --- Variabel dan Fungsi untuk Instalasi Node Exporter ---
NODE_EXPORTER_VERSION="1.7.0"
NE_INSTALL_DIR="/opt/node_exporter_bin"
NE_INSTALL_PATH="${NE_INSTALL_DIR}/node_exporter"
NE_ARCH_SUFFIX=""

echo "Detecting architecture..."
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  NE_ARCH_SUFFIX="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  NE_ARCH_SUFFIX="arm64"
else
  echo "Error: Unsupported architecture for node_exporter: $ARCH. Node exporter will not be installed."
fi

# --- Instalasi Node Exporter di Runtime ---
if [ ! -z "$NE_ARCH_SUFFIX" ]; then
  if [ -f "$NE_INSTALL_PATH" ]; then
    echo "Node exporter already found at $NE_INSTALL_PATH. Skipping download."
  else
    NE_TAR_FILENAME="node_exporter-${NODE_EXPORTER_VERSION}.linux-${NE_ARCH_SUFFIX}.tar.gz"
    NE_BIN_PATH_IN_ARCHIVE="node_exporter-${NODE_EXPORTER_VERSION}.linux-${NE_ARCH_SUFFIX}/node_exporter"
    NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NE_TAR_FILENAME}"
    
    echo "Creating install directory $NE_INSTALL_DIR..."
    mkdir -p "$NE_INSTALL_DIR"

    echo "Attempting to download node_exporter from ${NODE_EXPORTER_URL} to /tmp/${NE_TAR_FILENAME}..."
    DOWNLOAD_SUCCESS="false"
    if command -v curl > /dev/null; then
      if curl -sSL "${NODE_EXPORTER_URL}" -o "/tmp/${NE_TAR_FILENAME}"; then
        DOWNLOAD_SUCCESS="true"
      fi
    elif command -v wget > /dev/null; then
      if wget -q "${NODE_EXPORTER_URL}" -O "/tmp/${NE_TAR_FILENAME}"; then
        DOWNLOAD_SUCCESS="true"
      fi
    else
      echo "Error: wget and curl are not available. Cannot download node_exporter."
    fi

    if [ "$DOWNLOAD_SUCCESS" = "true" ] && [ -f "/tmp/${NE_TAR_FILENAME}" ]; then
      echo "Download successful. Extracting node_exporter..."
      tar xvfz "/tmp/${NE_TAR_FILENAME}" -C /tmp/
      if [ -f "/tmp/${NE_BIN_PATH_IN_ARCHIVE}" ]; then
        mv "/tmp/${NE_BIN_PATH_IN_ARCHIVE}" "$NE_INSTALL_PATH"
        chmod +x "$NE_INSTALL_PATH"
        echo "node_exporter installed to $NE_INSTALL_PATH"
      else
        echo "Error: Failed to find node_exporter binary in archive at /tmp/${NE_BIN_PATH_IN_ARCHIVE}"
      fi
      rm -f "/tmp/${NE_TAR_FILENAME}"
      rm -rf "/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-${NE_ARCH_SUFFIX}"
    else
      echo "Error: Failed to download node_exporter. Check network connectivity from pod."
    fi
  fi
fi
# --- Akhir Instalasi Node Exporter ---

echo "Configuring IP for pc2..."
ip addr add 10.0.2.1/24 dev eth1 || echo "Warning: Failed to add IPv4 addr for pc2 or already exists."
ip route replace default via 10.0.2.2 dev eth1 || echo "Warning: Failed to set IPv4 default route for pc2 or already exists."
ip -6 addr add 2001:4b::2/64 dev eth1 || echo "Warning: Failed to add IPv6 addr for pc2 or already exists."
ip -6 route replace default via 2001:4b::1 dev eth1 || echo "Warning: Failed to set IPv6 default route for pc2 or already exists."
echo "IP configuration for pc2 finished."

echo "Starting node_exporter..."
if [ -f "$NE_INSTALL_PATH" ]; then
  if pgrep -x "$(basename $NE_INSTALL_PATH)" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Attempting to start node_exporter from $NE_INSTALL_PATH in background..."
    "$NE_INSTALL_PATH" --web.listen-address=":9100" &
    echo "node_exporter start command issued."
    sleep 1
    if pgrep -x "$(basename $NE_INSTALL_PATH)" > /dev/null ; then
        echo "node_exporter process confirmed running."
    else
        echo "node_exporter process NOT confirmed running after 1s check."
    fi
  fi
else
  echo "Node_exporter binary not found at $NE_INSTALL_PATH. Not starting."
fi

echo "init.sh script finished for PC1. Container will keep running."
tail -f /dev/null