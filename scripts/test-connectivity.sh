#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/test-common.sh"
check_test_environment

echo "===== TAILSCALE CONNECTIVITY TEST ====="

docker exec tailscale-b tailscale ping \
    --timeout=10s 100.104.64.49

echo "PASS: Organisation B can reach Organisation A through Tailscale."
