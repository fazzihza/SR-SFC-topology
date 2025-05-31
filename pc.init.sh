#!/bin/sh
echo "Custom PC Init: Configuring IP and Starting Node Exporter"

# Konfigurasi IP akan bergantung pada bagaimana Anda ingin menyediakannya.
# Jika menggunakan variabel environment yang diset oleh Clabernetes:
# Misalnya, IP_ADDR="10.0.0.1/24" DEFAULT_GW="10.0.0.2" IFACE="eth1"
# IP_ADDR6="2001:fa::2/64" DEFAULT_GW6="2001:fa::1"
# if [ ! -z "$IP_ADDR" ] && [ ! -z "$DEFAULT_GW" ] && [ ! -z "$IFACE" ]; then
#   echo "Configuring IPv4: $IP_ADDR gw $DEFAULT_GW dev $IFACE"
#   ip addr add $IP_ADDR dev $IFACE || true
#   ip route replace default via $DEFAULT_GW dev $IFACE || true
# else
#   echo "IPv4 variables not set, skipping IPv4 config in init.sh"
# fi
# if [ ! -z "$IP_ADDR6" ] && [ ! -z "$DEFAULT_GW6" ] && [ ! -z "$IFACE" ]; then
#   echo "Configuring IPv6: $IP_ADDR6 gw $DEFAULT_GW6 dev $IFACE"
#   ip -6 addr add $IP_ADDR6 dev $IFACE || true
#   ip -6 route replace default via $DEFAULT_GW6 dev $IFACE || true
# else
#   echo "IPv6 variables not set, skipping IPv6 config in init.sh"
# fi
# Karena Clabernetes tidak secara langsung menyuntikkan variabel per-node seperti ini
# ke skrip init dengan mudah, lebih baik tetap gunakan blok 'exec' di clab.yml untuk PC
# atau buat image PC yang berbeda untuk pc1 dan pc2 jika init.sh di-hardcode.
# Untuk contoh ini, kita biarkan IP config dilakukan oleh 'exec' di clab.yml dan init.sh ini hanya untuk node_exporter.

echo "Starting node_exporter (from image)..."
if [ -f /usr/local/bin/node_exporter ]; then
  if ! pgrep -x "node_exporter" > /dev/null ; then
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    sleep 1 && pgrep -x "node_exporter" > /dev/null && echo "Node Exporter process confirmed running." || echo "Node Exporter process NOT confirmed running."
  else
    echo "Node Exporter is already running."
  fi
else
  echo "FATAL: node_exporter not found at /usr/local/bin/node_exporter in image."
fi

echo "PC Init script finished. Container will keep running via tail."
tail -f /dev/null # Penting agar kontainer PC tetap berjalan