#!/bin/sh

echo "PC2 Init Script: Configuring IP and starting pre-mounted node_exporter"

echo "Configuring IP for pc2..."
ip addr add 10.0.2.1/24 dev eth1 || true
ip route replace default via 10.0.2.2 dev eth1 || true
ip -6 addr add 2001:4b::2/64 dev eth1 || true
ip -6 route replace default via 2001:4b::1 dev eth1 || true
echo "IP configuration for pc2 finished."

if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Starting pre-mounted node_exporter..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter started."
  fi
else
  echo "FATAL: Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter. Please check clab binds and host file path ./exporter_bin/node_exporter"
fi

echo "init.sh script finished. Container will keep running."
tail -f /dev/null