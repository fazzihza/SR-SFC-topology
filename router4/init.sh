#!/bin/sh

echo "Router Init Script (Kubernetes/Clabernetes): Installing Node Exporter, then starting FRR, hsflowd"

# --- Variabel dan Fungsi untuk Instalasi Node Exporter ---
NODE_EXPORTER_VERSION="1.7.0"
NE_INSTALL_DIR="/opt/node_exporter_bin" # Direktori instalasi di dalam kontainer
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
      echo "Error: Failed to download node_exporter. Check network connectivity and URL."
    fi
  fi
fi
# --- Akhir Instalasi Node Exporter ---

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

echo "Applying kernel settings and FRR permissions..."
sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null 2>&1
if chown -R frr:frr /etc/frr; then
  echo "Set /etc/frr ownership to frr:frr."
else
  echo "Warning: Failed to set /etc/frr ownership."
fi
mkdir -p /var/run/frr
if chown frr:frr /var/run/frr; then
    echo "Set /var/run/frr ownership."
else
    echo "Warning: Failed to set /var/run/frr ownership."
fi
chmod 775 /var/run/frr
rm -f /var/run/frr/*.pid
rm -f /var/run/frr/watchfrr.pid
echo "Stale FRR PID files cleaned (if any)."

HSFLOWD_START_SCRIPT="/usr/bin/hsflowd_start.sh"
echo "Checking for hsflowd_start.sh and COLLECTOR env var..."
if [ ! -z "${COLLECTOR}" ] && [ -f "$HSFLOWD_START_SCRIPT" ]; then
  echo "COLLECTOR is set to ${COLLECTOR}. Starting hsflowd via $HSFLOWD_START_SCRIPT..."
  "$HSFLOWD_START_SCRIPT"
  sleep 1 
  if pgrep -f "/usr/sbin/hsflowd" > /dev/null; then
    echo "hsflowd process found running."
  else
    echo "hsflowd process NOT found after attempting start with $HSFLOWD_START_SCRIPT."
  fi
else
  if [ -z "${COLLECTOR}" ]; then
    echo "COLLECTOR environment variable is not set or empty. hsflowd will not be started by this script's logic."
  fi
  if [ ! -f "$HSFLOWD_START_SCRIPT" ]; then
    echo "$HSFLOWD_START_SCRIPT not found. Cannot start hsflowd using this method."
  fi
fi

FRR_START_SCRIPT_MAIN="/usr/lib/frr/docker-start"
echo "Now starting FRR as the main process using: $FRR_START_SCRIPT_MAIN"
if [ -f "$FRR_START_SCRIPT_MAIN" ]; then
  exec "$FRR_START_SCRIPT_MAIN"
else
  echo "ERROR: FRR start script $FRR_START_SCRIPT_MAIN not found! FRR cannot start."
  echo "Container will keep running via sleep to allow debugging."
  sleep infinity
fi