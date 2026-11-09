#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test-common.sh"
check_test_environment

echo "Testing IMAPS authentication on port 993..."

run_tester_interactive python3 /tests/test-imaps-auth.py
