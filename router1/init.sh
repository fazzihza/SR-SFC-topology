#!/bin/sh

echo "Router Init Script: Starting FRR and pre-mounted node_exporter"

if pgrep -x "watchfrr" > /dev/null ; then
  echo "FRR (watchfrr) is already running."
else
  echo "Starting FRR services..."
  rm -f /var/run/frr/*.pid /var/run/frr/watchfrr.pid
  if [ -f /usr/lib/frr/frrinit.sh ]; then
    /usr/lib/frr/frrinit.sh start
    echo "FRR services started."
  else
    echo "frrinit.sh not found."
  fi
fi

if [ -f /usr/local/bin/node_exporter ]; then
  if pgrep -x "node_exporter" > /dev/null ; then
    echo "node_exporter is already running."
  else
    echo "Starting pre-mounted node_exporter..."
    /usr/local/bin/node_exporter --web.listen-address=":9100" &
    echo "node_exporter started."
  fi
else
  echo "Pre-mounted node_exporter binary not found at /usr/local/bin/node_exporter."
fi

echo "init.sh script finished. Assuming hsflowd starts automatically if configured."
echo "Container will keep running."
tail -f /dev/null