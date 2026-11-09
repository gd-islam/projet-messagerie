#!/bin/bash

set -e

echo "=================================="
echo " Starting VARYS mail filter"
echo "=================================="

echo "[1/3] Starting ClamAV daemon..."
service clamav-daemon start

echo "[2/3] Waiting for ClamAV socket..."

for i in $(seq 1 30); do
    if [ -S /var/run/clamav/clamd.ctl ]; then
        break
    fi
    sleep 1
done

if [ ! -S /var/run/clamav/clamd.ctl ]; then
    echo "ERROR: ClamAV socket was not created."
    exit 1
fi

echo "ClamAV socket is ready."

echo "[3/3] Starting FreshClam..."
service clamav-freshclam start

echo "Starting Amavis..."
service amavis start

echo "All filtering services started."

# Keep the container alive and handle shutdown.
cleanup() {
    echo "Stopping filtering services..."
    service amavis stop || true
    service clamav-freshclam stop || true
    service clamav-daemon stop || true
}

trap cleanup EXIT

tail -f /dev/null &
wait $!
