#!/bin/sh

echo "Router Init Script: Starting FRR, node_exporter, and hsflowd"

echo "Starting node_exporter (pre-mounted)..."
if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Attempting to start pre-mounted node_exporter in background..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter start command issued."
    sleep 1
    if pgrep -x "node_exporter" > /dev/null ; then
        echo "node_exporter process confirmed running."
    else
        echo "node_exporter process NOT confirmed running after 1s check."
    fi
  fi
else
  echo "FATAL: Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter. Check clab binds and host path ./exporter_bin/node_exporter"
fi

HSFLOWD_START_SCRIPT="/usr/bin/hsflowd_start.sh"
echo "Checking for hsflowd_start.sh and COLLECTOR env var..."
if [ ! -z "${COLLECTOR}" ] && [ -f "$HSFLOWD_START_SCRIPT" ]; then
  echo "COLLECTOR is set to ${COLLECTOR}. Starting hsflowd via $HSFLOWD_START_SCRIPT..."
  "$HSFLOWD_START_SCRIPT"
  sleep 1 
  if pgrep -f "/usr/sbin/hsflowd" > /dev/null; then
    echo "hsflowd process found running."
  else
    echo "hsflowd process NOT found after attempting start with $HSFLOWD_START_SCRIPT."
  fi
else
  if [ -z "${COLLECTOR}" ]; then
    echo "COLLECTOR environment variable is not set or empty. hsflowd will not be started by this script's logic."
  fi
  if [ ! -f "$HSFLOWD_START_SCRIPT" ]; then
    echo "$HSFLOWD_START_SCRIPT not found. Cannot start hsflowd using this method."
  fi
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

echo "Preparing FRR runtime directory and cleaning stale PIDs..."
mkdir -p /var/run/frr
if chown frr:frr /var/run/frr; then
    echo "Set /var/run/frr ownership."
else
    echo "Failed to set /var/run/frr ownership."
fi
chmod 775 /var/run/frr
rm -f /var/run/frr/*.pid
rm -f /var/run/frr/watchfrr.pid
echo "Stale FRR PID files cleaned."

FRR_START_SCRIPT_MAIN="/usr/lib/frr/docker-start"
echo "Now starting FRR as the main process using: $FRR_START_SCRIPT_MAIN"
if [ -f "$FRR_START_SCRIPT_MAIN" ]; then
  exec "$FRR_START_SCRIPT_MAIN"
else
  echo "ERROR: FRR start script $FRR_START_SCRIPT_MAIN not found! FRR cannot start."
  echo "Container will keep running via sleep to allow debugging."
  sleep infinity
fi