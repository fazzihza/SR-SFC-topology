#!/bin/sh

echo "Router Init Script: Starting FRR, hsflowd, and pre-mounted node_exporter"

if pgrep -x "watchfrr" > /dev/null ; then
  echo "FRR (watchfrr) is already running."
else
  echo "Starting FRR services..."
  rm -f /var/run/frr/*.pid /var/run/frr/watchfrr.pid
  if [ -f /usr/lib/frr/frrinit.sh ]; then
    /usr/lib/frr/frrinit.sh start
    echo "FRR services started."
  else
    echo "frrinit.sh not found."
  fi
fi

if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Starting pre-mounted node_exporter..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter started."
  fi
else
  echo "Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter."
fi

echo "Checking and starting hsflowd service..."
HSFLOWD_INIT_SCRIPT="/etc/init.d/hsflowd"
if [ -f "$HSFLOWD_INIT_SCRIPT" ]; then
  if ! pgrep -x "hsflowd" > /dev/null; then
    echo "hsflowd not running, attempting to start..."
    "$HSFLOWD_INIT_SCRIPT" start
    sleep 1 # Beri waktu sedikit untuk proses dimulai
    if pgrep -x "hsflowd" > /dev/null; then
      echo "hsflowd started successfully."
    else
      echo "Failed to start hsflowd using init script."
    fi
  else
    echo "hsflowd is already running."
  fi
else
  echo "$HSFLOWD_INIT_SCRIPT not found. Cannot manage hsflowd service."
fi

echo "init.sh script finished. Container will keep running."
tail -f /dev/null