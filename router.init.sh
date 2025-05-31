#!/bin/sh
echo "Custom Router Init: Starting Node Exporter, FRR, hsflowd"

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

echo "Applying kernel settings and FRR permissions..."
sysctl -w net.ipv6.conf.all.forwarding=1 > /dev/null 2>&1
chown -R frr:frr /etc/frr # Ini mungkin tidak diperlukan jika izin sudah benar dari ConfigMap
mkdir -p /var/run/frr
chown frr:frr /var/run/frr # Atau frr:vty
chmod 775 /var/run/frr
rm -f /var/run/frr/*.pid
rm -f /var/run/frr/watchfrr.pid
echo "Stale FRR PID files cleaned."

HSFLOWD_START_SCRIPT="/usr/bin/hsflowd_start.sh" # Path ini ada di image sflow/clab-frr
echo "Checking for hsflowd_start.sh and COLLECTOR env var..."
if [ ! -z "${COLLECTOR}" ] && [ -f "$HSFLOWD_START_SCRIPT" ]; then
  echo "COLLECTOR is set to ${COLLECTOR}. Starting hsflowd via $HSFLOWD_START_SCRIPT..."
  "$HSFLOWD_START_SCRIPT"
  sleep 1
  pgrep -f "/usr/sbin/hsflowd" > /dev/null && echo "hsflowd process found." || echo "hsflowd process NOT found."
else
  echo "Skipping hsflowd start: COLLECTOR not set or $HSFLOWD_START_SCRIPT not found."
fi

FRR_START_SCRIPT_MAIN="/usr/lib/frr/docker-start" # Path ini ada di image sflow/clab-frr
echo "Now starting FRR as the main process using: $FRR_START_SCRIPT_MAIN"
if [ -f "$FRR_START_SCRIPT_MAIN" ]; then
  exec "$FRR_START_SCRIPT_MAIN"
else
  echo "ERROR: FRR start script $FRR_START_SCRIPT_MAIN not found! FRR cannot start."
  sleep infinity
fi