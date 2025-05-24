#!/bin/bash

# Periksa apakah watchfrr sudah berjalan untuk menghindari konflik PID
if pgrep -x "watchfrr" > /dev/null
then
    echo "FRR (watchfrr) is already running."
else
    echo "Starting FRR services..."
    # Hapus file PID lama jika ada, untuk mengatasi masalah "Resource temporarily unavailable"
    rm -f /var/run/frr/*.pid
    rm -f /var/run/frr/watchfrr.pid

    if [ -f /usr/lib/frr/frrinit.sh ]; then
      /usr/lib/frr/frrinit.sh start
      if [ $? -ne 0 ]; then
        echo "Failed to start FRR services with frrinit.sh."
      else
        echo "FRR services started via frrinit.sh."
      fi
    else
      echo "frrinit.sh not found, attempting to start daemons manually (not recommended)."
      # Fallback ini sebaiknya dihindari jika frrinit.sh tersedia
      /usr/sbin/zebra -d -f /etc/frr/zebra.conf
      /usr/sbin/bgpd -d -f /etc/frr/bgpd.conf
    fi
fi

FRR_EXPORTER_VERSION="1.6.0" # Versi lebih baru dan terverifikasi
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
  ARCH_SUFFIX="amd64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_SUFFIX="arm64"
else
  echo "Unsupported architecture: $ARCH for frr-exporter. Exiting."
  tail -f /dev/null # Tetap jalankan kontainer jika terjadi kesalahan
  exit 1
fi

FRR_EXPORTER_TAR="frr_exporter-${FRR_EXPORTER_VERSION}.linux-${ARCH_SUFFIX}.tar.gz"
FRR_EXPORTER_URL="https://github.com/prometheus-community/frr_exporter/releases/download/v${FRR_EXPORTER_VERSION}/${FRR_EXPORTER_TAR}"
FRR_EXPORTER_BIN_PATH="frr_exporter-${FRR_EXPORTER_VERSION}.linux-${ARCH_SUFFIX}/frr_exporter"


echo "Downloading frr-exporter v${FRR_EXPORTER_VERSION} for ${ARCH_SUFFIX} from ${FRR_EXPORTER_URL}"
wget -q "${FRR_EXPORTER_URL}" -O "/tmp/${FRR_EXPORTER_TAR}"

if [ $? -ne 0 ]; then
  echo "Failed to download frr-exporter. Please check network connectivity and URL."
  echo "URL attempted: ${FRR_EXPORTER_URL}"
else
  echo "Download successful. Extracting frr-exporter..."
  # Ekstrak hanya binary frr_exporter ke /usr/local/bin/
  tar -xzf "/tmp/${FRR_EXPORTER_TAR}" -C /tmp/
  if [ -f "/tmp/${FRR_EXPORTER_BIN_PATH}" ]; then
    mv "/tmp/${FRR_EXPORTER_BIN_PATH}" /usr/local/bin/frr_exporter
    chmod +x /usr/local/bin/frr_exporter
    echo "frr-exporter installed to /usr/local/bin/frr_exporter"
  else
    echo "Failed to find frr_exporter binary in the archive at /tmp/${FRR_EXPORTER_BIN_PATH}"
  fi
  rm -rf "/tmp/${FRR_EXPORTER_TAR}" "/tmp/frr_exporter-${FRR_EXPORTER_VERSION}.linux-${ARCH_SUFFIX}" # Hapus arsip dan direktori hasil ekstraksi
fi

if [ -f /usr/local/bin/frr_exporter ]; then
  # Periksa apakah frr-exporter sudah berjalan
  if pgrep -x "frr_exporter" > /dev/null
  then
    echo "frr-exporter is already running."
  else
    echo "Starting frr-exporter..."
    /usr/local/bin/frr_exporter --web.listen-address=":9342" &
    if [ $? -ne 0 ]; then
        echo "Failed to start frr-exporter."
    else
        echo "frr-exporter started."
    fi
  fi
else
  echo "frr_exporter binary not found at /usr/local/bin/frr_exporter. Not starting exporter."
fi

echo "init.sh script finished. Container will keep running."
# Jaga agar kontainer tetap berjalan
tail -f /dev/null