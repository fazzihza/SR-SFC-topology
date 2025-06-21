#!/bin/bash
# Skrip ini akan membuat semua 40 ConfigMap yang diperlukan untuk topologi Clabernetes.
# Pastikan Anda sudah login ke MicroK8s dan berada di direktori yang benar.

NAMESPACE="c9s-srv6-mesh"

echo "Membuat ConfigMaps di namespace: $NAMESPACE"
echo "==============================================="

# --- Untuk Router 1 ---
echo "Membuat config untuk router1..."
microk8s kubectl create configmap router1-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router1/frr.conf
microk8s kubectl create configmap router1-daemons-config -n ${NAMESPACE} --from-file=daemons=./router1/daemons

# --- Untuk Router 2 ---
echo "Membuat config untuk router2..."
microk8s kubectl create configmap router2-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router2/frr.conf
microk8s kubectl create configmap router2-daemons-config -n ${NAMESPACE} --from-file=daemons=./router2/daemons

# --- Untuk Router 3 ---
echo "Membuat config untuk router3..."
microk8s kubectl create configmap router3-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router3/frr.conf
microk8s kubectl create configmap router3-daemons-config -n ${NAMESPACE} --from-file=daemons=./router3/daemons

# --- Untuk Router 4 ---
echo "Membuat config untuk router4..."
microk8s kubectl create configmap router4-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router4/frr.conf
microk8s kubectl create configmap router4-daemons-config -n ${NAMESPACE} --from-file=daemons=./router4/daemons

# --- Untuk Router 5 ---
echo "Membuat config untuk router5..."
microk8s kubectl create configmap router5-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router5/frr.conf
microk8s kubectl create configmap router5-daemons-config -n ${NAMESPACE} --from-file=daemons=./router5/daemons

# --- Untuk Router 6 ---
echo "Membuat config untuk router6..."
microk8s kubectl create configmap router6-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router6/frr.conf
microk8s kubectl create configmap router6-daemons-config -n ${NAMESPACE} --from-file=daemons=./router6/daemons

# --- Untuk Router 7 ---
echo "Membuat config untuk router7..."
microk8s kubectl create configmap router7-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router7/frr.conf
microk8s kubectl create configmap router7-daemons-config -n ${NAMESPACE} --from-file=daemons=./router7/daemons

# --- Untuk Router 8 ---
echo "Membuat config untuk router8..."
microk8s kubectl create configmap router8-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router8/frr.conf
microk8s kubectl create configmap router8-daemons-config -n ${NAMESPACE} --from-file=daemons=./router8/daemons

# --- Untuk Router 9 ---
echo "Membuat config untuk router9..."
microk8s kubectl create configmap router9-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router9/frr.conf
microk8s kubectl create configmap router9-daemons-config -n ${NAMESPACE} --from-file=daemons=./router9/daemons

# --- Untuk Router 10 ---
echo "Membuat config untuk router10..."
microk8s kubectl create configmap router10-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router10/frr.conf
microk8s kubectl create configmap router10-daemons-config -n ${NAMESPACE} --from-file=daemons=./router10/daemons

# --- Untuk Router 11 ---
echo "Membuat config untuk router11..."
microk8s kubectl create configmap router11-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router11/frr.conf
microk8s kubectl create configmap router11-daemons-config -n ${NAMESPACE} --from-file=daemons=./router11/daemons

# --- Untuk Router 12 ---
echo "Membuat config untuk router12..."
microk8s kubectl create configmap router12-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router12/frr.conf
microk8s kubectl create configmap router12-daemons-config -n ${NAMESPACE} --from-file=daemons=./router12/daemons

# --- Untuk Router 13 ---
echo "Membuat config untuk router13..."
microk8s kubectl create configmap router13-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router13/frr.conf
microk8s kubectl create configmap router13-daemons-config -n ${NAMESPACE} --from-file=daemons=./router13/daemons

# --- Untuk Router 14 ---
echo "Membuat config untuk router14..."
microk8s kubectl create configmap router14-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router14/frr.conf
microk8s kubectl create configmap router14-daemons-config -n ${NAMESPACE} --from-file=daemons=./router14/daemons

# --- Untuk Router 15 ---
echo "Membuat config untuk router15..."
microk8s kubectl create configmap router15-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router15/frr.conf
microk8s kubectl create configmap router15-daemons-config -n ${NAMESPACE} --from-file=daemons=./router15/daemons

# --- Untuk Router 16 ---
echo "Membuat config untuk router16..."
microk8s kubectl create configmap router16-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router16/frr.conf
microk8s kubectl create configmap router16-daemons-config -n ${NAMESPACE} --from-file=daemons=./router16/daemons

# --- Untuk Router 17 ---
echo "Membuat config untuk router17..."
microk8s kubectl create configmap router17-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router17/frr.conf
microk8s kubectl create configmap router17-daemons-config -n ${NAMESPACE} --from-file=daemons=./router17/daemons

# --- Untuk Router 18 ---
echo "Membuat config untuk router18..."
microk8s kubectl create configmap router18-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router18/frr.conf
microk8s kubectl create configmap router18-daemons-config -n ${NAMESPACE} --from-file=daemons=./router18/daemons

# --- Untuk Router 19 ---
echo "Membuat config untuk router19..."
microk8s kubectl create configmap router19-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router19/frr.conf
microk8s kubectl create configmap router19-daemons-config -n ${NAMESPACE} --from-file=daemons=./router19/daemons

# --- Untuk Router 20 ---
echo "Membuat config untuk router20..."
microk8s kubectl create configmap router20-frr-config -n ${NAMESPACE} --from-file=frr.conf=./router20/frr.conf
microk8s kubectl create configmap router20-daemons-config -n ${NAMESPACE} --from-file=daemons=./router20/daemons

echo ""
echo "==============================================="
echo "Semua ConfigMap berhasil dibuat."