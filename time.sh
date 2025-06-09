#!/bin/bash

echo "Memulai proses deployment..."
start_time=$(date +%s%N) # Waktu mulai dalam nanoseconds

# Deploy topologi Anda
clabverter --stdout --naming non-prefixed | \
microk8s kubectl apply -f -

# Tunggu sampai semua pod dalam topologi siap
microk8s kubectl wait --for=condition=Ready pod \
  -l clabernetes.io/topology-name=nama-topologi-anda \
  --timeout=10m

end_time=$(date +%s%N) # Waktu selesai dalam nanoseconds

# Hitung durasi dalam milidetik
duration=$((($end_time - $start_time) / 1000000))

echo "Proses deployment selesai dalam: $duration ms"