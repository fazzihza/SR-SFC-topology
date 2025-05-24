#!/bin/bash

if [ -f /usr/lib/frr/frrinit.sh ]; then
  /usr/lib/frr/frrinit.sh start
else
  /usr/sbin/zebra -d -f /etc/frr/zebra.conf
  /usr/sbin/bgpd -d -f /etc/frr/bgpd.conf
fi

echo "FRR services started."

FRR_EXPORTER_VERSION="1.4.0"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
fi

FRR_EXPORTER_TAR="frr_exporter-${FRR_EXPORTER_VERSION}.linux-${ARCH}.tar.gz"
FRR_EXPORTER_URL="https://github.com/prometheus-community/frr_exporter/releases/download/v${FRR_EXPORTER_VERSION}/${FRR_EXPORTER_TAR}"

echo "Downloading frr-exporter from ${FRR_EXPORTER_URL}"
wget -q "${FRR_EXPORTER_URL}" -O "/tmp/${FRR_EXPORTER_TAR}"

if [ $? -ne 0 ]; then
  echo "Failed to download frr-exporter"
  FALLBACK_URL="https://github.com/prometheus-community/frr_exporter/releases/download/v1.4.0/frr_exporter-1.4.0.linux-amd64.tar.gz"
  echo "Attempting fallback download: ${FALLBACK_URL}"
  wget -q "${FALLBACK_URL}" -O "/tmp/frr_exporter-fallback.tar.gz"
  if [ $? -eq 0 ]; then
    tar -xzf "/tmp/frr_exporter-fallback.tar.gz" -C /usr/local/bin/ --strip-components=1 "frr_exporter-${FRR_EXPORTER_VERSION}.linux-amd64/frr_exporter"
  else
    echo "Fallback download also failed. Exporter not started."
    tail -f /dev/null
    exit 1
  fi
else
  tar -xzf "/tmp/${FRR_EXPORTER_TAR}" -C /usr/local/bin/ --strip-components=1 "frr_exporter-${FRR_EXPORTER_VERSION}.linux-${ARCH}/frr_exporter"
fi

rm -f "/tmp/${FRR_EXPORTER_TAR}" "/tmp/frr_exporter-fallback.tar.gz"

if [ -f /usr/local/bin/frr_exporter ]; then
  echo "Starting frr-exporter..."
  /usr/local/bin/frr_exporter --web.listen-address=":9342" &
else
  echo "frr_exporter not found. Not starting exporter."
fi

echo "init.sh script finished. Container will keep running."
tail -f /dev/null