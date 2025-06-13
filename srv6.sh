#!/bin/bash

# Menentukan namespace tempat topologi Anda berjalan
NAMESPACE="c9s-srsfc"

# --- Langkah 1: Dapatkan nama pod yang sedang berjalan saat ini ---
echo "Mencari nama pod terbaru..."
POD_R1=$(microk8s kubectl get pods -n $NAMESPACE -l "clabernetes.io/node-name=router1" -o jsonpath='{.items[0].metadata.name}')
POD_R2=$(microk8s kubectl get pods -n $NAMESPACE -l "clabernetes.io/node-name=router2" -o jsonpath='{.items[0].metadata.name}')
POD_R3=$(microk8s kubectl get pods -n $NAMESPACE -l "clabernetes.io/node-name=router3" -o jsonpath='{.items[0].metadata.name}')
POD_R4=$(microk8s kubectl get pods -n $NAMESPACE -l "clabernetes.io/node-name=router4" -o jsonpath='{.items[0].metadata.name}')

# Memeriksa apakah semua pod ditemukan
if [ -z "$POD_R1" ] || [ -z "$POD_R2" ] || [ -z "$POD_R3" ] || [ -z "$POD_R4" ]; then
    echo "Error: Tidak dapat menemukan satu atau lebih pod router di namespace '$NAMESPACE'."
    echo "Pastikan topologi Anda sudah berjalan."
    exit 1
fi

echo "Pod ditemukan: R1=$POD_R1, R2=$POD_R2, R3=$POD_R3, R4=$POD_R4"
echo "--- Menerapkan Konfigurasi SRv6 ---"

# --- Konfigurasi Router 1 ---
echo "Mengkonfigurasi Router 1..."
microk8s kubectl exec -it $POD_R1 -n $NAMESPACE -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
microk8s kubectl exec -it $POD_R1 -n $NAMESPACE -- ip -6 route replace 2001:4b::/64 encap seg6 mode encap segs fc00:2::bb,fc00:3::bb,fc00:4::bb dev router1-eth1 metric 10

# --- Konfigurasi Router 2 ---
echo "Mengkonfigurasi Router 2..."
microk8s kubectl exec -it $POD_R2 -n $NAMESPACE -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
microk8s kubectl exec -it $POD_R2 -n $NAMESPACE -- ip -6 route replace fc00:2::bb/128 encap seg6local action End dev router2-eth2

# --- Konfigurasi Router 3 ---
echo "Mengkonfigurasi Router 3..."
microk8s kubectl exec -it $POD_R3 -n $NAMESPACE -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
microk8s kubectl exec -it $POD_R3 -n $NAMESPACE -- ip -6 route replace fc00:3::bb/128 encap seg6local action End dev router3-eth3

# --- Konfigurasi Router 4 ---
echo "Mengkonfigurasi Router 4..."
microk8s kubectl exec -it $POD_R4 -n $NAMESPACE -- sysctl -w net.ipv6.conf.all.seg6_enabled=1
microk8s kubectl exec -it $POD_R4 -n $NAMESPACE -- ip -6 route replace fc00:4::bb/128 encap seg6local action End.DX6 nh6 2001:4b::2 dev router4-eth3

echo "--- Konfigurasi SRv6 Selesai ---"