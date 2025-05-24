#!/bin/sh

echo "Attempting to install and run node_exporter on sflow-rt node."

NODE_EXPORTER_VERSION="1.7.0"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH_SUFFIX="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_SUFFIX="arm64"
else
  echo "Unsupported architecture: $ARCH for node_exporter. Exporter not started."
  tail -f /dev/null
  exit 1
fi

NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_SUFFIX}.tar.gz"
NODE_EXPORTER_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}"
NODE_EXPORTER_BIN_DIR="/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-${ARCH_SUFFIX}"
NODE_EXPORTER_BIN_PATH="${NODE_EXPORTER_BIN_DIR}/node_exporter"

if [ -f /usr/local/bin/node_exporter ]; then
    echo "node_exporter already installed."
else
    echo "Downloading node_exporter v${NODE_EXPORTER_VERSION} for ${ARCH_SUFFIX} from ${NODE_EXPORTER_URL}"
    wget -q "${NODE_EXPORTER_URL}" -O "/tmp/${NODE_EXPORTER_TAR}"

    if [ $? -ne 0 ]; then
      echo "Failed to download node_exporter. URL: ${NODE_EXPORTER_URL}"
    else
      echo "Download successful. Extracting node_exporter..."
      tar -xzf "/tmp/${NODE_EXPORTER_TAR}" -C /tmp/
      if [ -f "${NODE_EXPORTER_BIN_PATH}" ]; then
        mv "${NODE_EXPORTER_BIN_PATH}" /usr/local/bin/node_exporter
        chmod +x /usr/local/bin/node_exporter
        echo "node_exporter installed to /usr/local/bin/node_exporter"
      else
        echo "Failed to find node_exporter binary in the archive at ${NODE_EXPORTER_BIN_PATH}"
      fi
      rm -f "/tmp/${NODE_EXPORTER_TAR}"
      rm -rf "${NODE_EXPORTER_BIN_DIR}"
    fi
fi

if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null
  then
    echo "node_exporter is already running."
  else
    echo "Starting node_exporter..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter started."
  fi
else
  echo "node_exporter binary not found. Not starting exporter."
fi

echo "init.sh script for sflow-rt finished. sflow-rt main process should keep container running."
echo "If sflow-rt doesn't keep container alive, add 'tail -f /dev/null' here."
sleep infinity