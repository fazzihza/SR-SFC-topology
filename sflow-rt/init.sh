#!/bin/sh

echo "sflow-rt Init Script: Starting pre-mounted node_exporter AND sFlow-RT application"

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

SFLOW_RT_START_SCRIPT="/sflow-rt/start.sh"
if [ -f "$SFLOW_RT_START_SCRIPT" ]; then
  echo "Executing sFlow-RT start script: $SFLOW_RT_START_SCRIPT"
  exec "$SFLOW_RT_START_SCRIPT"
else
  echo "ERROR: sFlow-RT start script $SFLOW_RT_START_SCRIPT not found!"
  echo "sFlow-RT application will not start. Container will sleep."
  sleep infinity
fi