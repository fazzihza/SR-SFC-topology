#!/bin/sh

CONF='/etc/hsflowd.conf'
NEIGHBORS="${NEIGHBORS:-eth1 eth2}"
SAMPLING="${SAMPLING:-1000}"
POLLING="${POLLING:-30}"
COLLECTOR="${COLLECTOR:-none}"

# Buat konfigurasi hsflowd (sFlow daemon)
printf "sflow {\n" > $CONF
printf " sampling=$SAMPLING\n" >> $CONF
printf " polling=$POLLING\n" >> $CONF
if [ "$COLLECTOR" != "none" ]; then
  printf " collector { ip=$COLLECTOR }\n" >> $CONF
fi
for dev in $NEIGHBORS; do
  printf " pcap { dev=$dev }\n" >> $CONF
done
printf "}\n" >> $CONF

# Aktifkan IPv6 forwarding di kernel (penting supaya routing IPv6 aktif)
sysctl -w net.ipv6.conf.all.forwarding=1

# Pastikan permission config FRR benar supaya daemon bisa baca
chown -R frr:frr /etc/frr

# Jalankan hsflowd jika ada collector sFlow
if [ "$COLLECTOR" != "none" ]; then
  /usr/sbin/hsflowd &
fi

# Jalankan daemon FRR, yang akan load /etc/frr/frr.conf (konfigurasi routing)
exec /usr/lib/frr/docker-start
