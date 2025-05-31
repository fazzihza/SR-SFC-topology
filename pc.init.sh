#!/bin/sh

echo "Custom PC Init Script (from Image): Starting Node Exporter"

NODE_EXPORTER_PATH="/usr/local/bin/node_exporter" # Path tempat node_exporter ada di dalam image

echo "Starting node_exporter (from image)..."
if [ -f "$NODE_EXPORTER_PATH" ]; then
  if pgrep -x "node_exporter" > /dev/null ; then # Cek apakah sudah berjalan
    echo "Node Exporter is already running."
  else
    echo "Attempting to start node_exporter from $NODE_EXPORTER_PATH in background..."
    "$NODE_EXPORTER_PATH" --web.listen-address=":9100" &
    echo "node_exporter start command issued."
    sleep 1 # Beri waktu sejenak untuk node_exporter benar-benar start atau gagal
    if pgrep -x "node_exporter" > /dev/null ; then
        echo "Node Exporter process confirmed running."
    else
        echo "Node Exporter process NOT confirmed running after 1s check. Check Prometheus."
        # Jika ini terjadi, node_exporter mungkin crash setelah dimulai.
    fi
  fi
else
  echo "FATAL: node_exporter binary not found at $NODE_EXPORTER_PATH in the image."
fi

# echo "PC Init script finished. Container will keep running via tail." # Baris echo ini ada di versi sebelumnya
echo "PC Init script finished. Container will keep running." # Baris echo ini sedikit berbeda dari sebelumnya, tapi intinya sama
tail -f /dev/null # <-- BARIS INI SANGAT PENTING untuk menjaga kontainer tetap hidup