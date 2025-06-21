#!/bin/bash

# --- PENTING: Ganti nilai ini jika nama topologi Anda berbeda ---
# Nama ini harus sesuai dengan 'metadata.name' di file YAML Anda
TOPOLOGY_NAME="srv6-mesh"

# Definisikan namespace yang akan dibuat oleh Clabernetes
NAMESPACE="c9s-$TOPOLOGY_NAME"

echo "Memastikan tidak ada deployment lama..."
# Perintah ini akan mencoba menghapus, dan akan gagal jika tidak ada, itu tidak masalah.
microk8s kubectl delete topology "$TOPOLOGY_NAME" -n "$NAMESPACE" > /dev/null 2>&1
# Beri waktu beberapa detik agar namespace benar-benar hilang
sleep 5

echo "Memulai proses deployment untuk topologi: $TOPOLOGY_NAME di namespace: $NAMESPACE..."
start_time=$(date +%s%N) # Waktu mulai dalam nanoseconds

# Jalankan perintah clabverter dan apply
sudo docker run --user $(id -u) \
    -v $(pwd):/clabernetes/work --rm \
    ghcr.io/srl-labs/clabernetes/clabverter --stdout --naming non-prefixed | \
microk8s kubectl apply -f -

# Periksa apakah perintah apply berhasil sebelum melanjutkan
if [ $? -ne 0 ]; then
    echo "Error: Perintah 'kubectl apply' gagal. Deployment dibatalkan."
    exit 1
fi

echo "Menunggu topologi untuk mencapai status 'Ready'..."
# --- PERUBAHAN KRUSIAL ADA DI SINI ---
# Kita sekarang menunggu kondisi 'TopologyReady' pada resource 'topology' itu sendiri.
microk8s kubectl wait --for=condition=TopologyReady=True \
  topology/"$TOPOLOGY_NAME" \
  -n "$NAMESPACE" \
  --timeout=15m

# Periksa apakah perintah wait berhasil
if [ $? -ne 0 ]; then
    echo "Error: Waktu tunggu habis. Topologi tidak mencapai status 'Ready'."
    exit 1
fi

end_time=$(date +%s%N) # Waktu selesai dalam nanoseconds

# Hitung durasi dalam milidetik
duration=$((($end_time - $start_time) / 1000000))

echo "-----------------------------------------------------"
echo "Proses deployment selesai dalam: $duration ms"
echo "-----------------------------------------------------"
