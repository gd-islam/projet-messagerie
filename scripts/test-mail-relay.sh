#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/test-common.sh"
check_test_environment

echo "===== UNAUTHENTICATED RELAY TEST ====="

run_tester python3 /tests/test-mail-relay.py
