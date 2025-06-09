#!/bin/bash

# --- PENTING: Ganti nilai ini dengan nama topologi Anda ---
# Anda bisa menemukan nama ini di dalam file YAML topologi Anda di bawah metadata.name
TOPOLOGY_NAME="topology-sr.clab.yml" # Ganti "srsfc" dengan nama topologi Anda yang sebenarnya

echo "Memulai proses deployment untuk topologi: $TOPOLOGY_NAME..."
start_time=$(date +%s%N) # Waktu mulai dalam nanoseconds

# Jalankan perintah clabverter secara langsung (bukan sebagai alias)
# Perintah ini mengkonversi topologi Containerlab dan langsung meneruskannya ke kubectl
sudo docker run --user $(id -u) \
    -v $(pwd):/clabernetes/work --rm \
    ghcr.io/srl-labs/clabernetes/clabverter --stdout --naming non-prefixed | \
microk8s kubectl apply -f -

# Periksa apakah perintah apply berhasil sebelum melanjutkan
if [ $? -ne 0 ]; then
    echo "Error: Perintah 'kubectl apply' gagal. Deployment dibatalkan."
    exit 1
fi

echo "Menunggu semua pod dalam topologi siap..."
# Tunggu sampai semua pod dalam topologi siap
# Pastikan TOPOLOGY_NAME di atas sudah benar
microk8s kubectl wait --for=condition=Ready pod \
  -l clabernetes.io/topology-name=$TOPOLOGY_NAME \
  --timeout=15m # Timeout diperpanjang untuk topologi yang kompleks

# Periksa apakah perintah wait berhasil
if [ $? -ne 0 ]; then
    echo "Error: Waktu tunggu habis. Pod tidak siap dalam batas waktu yang ditentukan."
    exit 1
fi

end_time=$(date +%s%N) # Waktu selesai dalam nanoseconds

# Hitung durasi dalam milidetik
duration=$((($end_time - $start_time) / 1000000))

echo "-----------------------------------------------------"
echo "Proses deployment selesai dalam: $duration ms"
echo "-----------------------------------------------------"

