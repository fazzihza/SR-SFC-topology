#!/bin/sh

echo "Custom PC Init Script (from Image): DEBUGGING Node Exporter in FOREGROUND"

NODE_EXPORTER_PATH="/usr/local/bin/node_exporter"

echo "Starting node_exporter (from image) in FOREGROUND..."
if [ -f "$NODE_EXPORTER_PATH" ]; then
  echo "--- Node Exporter Output Starts Below ---"
  # Jalankan di foreground (tanpa &)
  "$NODE_EXPORTER_PATH" --web.listen-address=":9100"
  NE_EXIT_CODE=$? # Tangkap kode exit jika node_exporter berhenti
  echo "--- Node Exporter Output Ended ---"
  echo "Node Exporter (foreground) exited with code: $NE_EXIT_CODE"
else
  echo "FATAL: node_exporter binary not found at $NODE_EXPORTER_PATH in the image."
fi

echo "PC Init script finished. Container will stop if node_exporter (foreground) exited."
# Tidak ada tail -f /dev/null agar kontainer berhenti jika node_exporter berhenti,
# sehingga kita bisa lihat log lengkapnya.
# Jika node_exporter berjalan terus di foreground, kontainer juga akan terus berjalan.