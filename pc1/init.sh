#!/bin/sh

echo "PC1 Init Script: DEBUGGING node_exporter startup"

echo "Configuring IP for pc1..."
ip addr add 10.0.0.1/24 dev eth1 || true
ip route replace default via 10.0.0.2 dev eth1 || true
ip -6 addr add 2001:fa::2/64 dev eth1 || true
ip -6 route replace default via 2001:fa::1 dev eth1 || true
echo "IP configuration for pc1 finished."

echo "Checking for pre-mounted node_exporter binary..."
if [ -f /usr/local/bin/node_exporter ]; then
  echo "Found /usr/local/bin/node_exporter. Attempting to run it in FOREGROUND..."
  echo "--- Node Exporter Output Starts Below ---"
  /usr/local/bin/node_exporter --web.listen-address=":9100"
  NE_EXIT_CODE=$?
  echo "--- Node Exporter Output Ended ---"
  echo "Node Exporter exited with code: $NE_EXIT_CODE"
else
  echo "FATAL: Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter. Please check clab binds and host file path ./exporter_bin/node_exporter"
fi

echo "init.sh script finished for PC1. Container will likely stop if node_exporter exited or was foreground."