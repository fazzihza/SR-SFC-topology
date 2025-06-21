#!/bin/bash

echo "[INIT] Setting up FRR with frr.conf"

# Force FRR to load unified frr.conf
export FRR_CONF_FILE=/etc/frr/frr.conf

# Debug info
echo "[DEBUG] frr.conf content:"
cat $FRR_CONF_FILE

# Start FRR using init script
/usr/lib/frr/frrinit.sh start