#!/bin/sh

echo "Router Init Script: Configuring hsflowd, starting node_exporter, then FRR"

CONF='/etc/hsflowd.conf'
DEFAULT_INTERFACES="eth1 eth2 eth3"
NEIGHBORS_TO_MONITOR="${NEIGHBORS:-${DEFAULT_INTERFACES}}"
SAMPLING="${SAMPLING:-1000}"
POLLING="${POLLING:-30}"
COLLECTOR="${COLLECTOR:-none}"

echo "Generating /etc/hsflowd.conf..."
printf "sflow {\n" > "$CONF"
# Gunakan nama host container sebagai identitas agen sFlow jika memungkinkan
if command -v hostname > /dev/null; then
  AGENT_HOSTNAME=$(hostname)
  printf " agent = %s\n" "$AGENT_HOSTNAME" >> "$CONF"
fi
printf " sampling = %s\n" "$SAMPLING" >> "$CONF"
printf " polling = %s\n" "$POLLING" >> "$CONF"

if [ "$COLLECTOR" != "none" ] && [ ! -z "$COLLECTOR" ]; then
  printf " collector { ip = %s }\n" "$COLLECTOR" >> "$CONF"
else
  echo "Warning: COLLECTOR for sflow is not set or is 'none'. hsflowd may not send data."
fi

for dev in $NEIGHBORS_TO_MONITOR; do
  printf " pcap { dev = %s }\n" "$dev" >> "$CONF"
done
printf "}\n" >> "$CONF"

echo "hsflowd.conf content:"
cat "$CONF"

if [ "$COLLECTOR" != "none" ] && [ ! -z "$COLLECTOR" ]; then
  if [ -f /usr/sbin/hsflowd ]; then
    echo "Starting hsflowd in background..."
    /usr/sbin/hsflowd &
    sleep 1
    if pgrep -f "/usr/sbin/hsflowd" > /dev/null; then
      echo "hsflowd process found."
    else
      echo "hsflowd process NOT found after attempting start."
    fi
  else
    echo "/usr/sbin/hsflowd not found. Cannot start hsflowd."
  fi
else
  echo "hsflowd not started because COLLECTOR is not configured."
fi

echo "Starting node_exporter..."
if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Starting pre-mounted node_exporter in background..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter started."
  fi
else
  echo "Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter. Please check clab binds and host file path ./exporter_bin/node_exporter"
fi

echo "Applying kernel settings and FRR permissions..."
if sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null; then
  echo "IPv6 forwarding enabled."
else
  echo "Failed to enable IPv6 forwarding."
fi
if chown -R frr:frr /etc/frr; then
  echo "Set /etc/frr ownership to frr:frr."
else
  echo "Failed to set /etc/frr ownership."
fi

FRR_START_SCRIPT="/usr/lib/frr/docker-start"
echo "Now starting FRR in background using: $FRR_START_SCRIPT"
if [ -f "$FRR_START_SCRIPT" ]; then
  "$FRR_START_SCRIPT" &
  echo "FRR started in background."
else
  echo "ERROR: FRR start script $FRR_START_SCRIPT not found! FRR cannot start."
fi

# Tambahkan sleep infinity agar container tetap hidup
echo "Init script finished. Container will stay alive."
sleep infinity