#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test-common.sh"
check_test_environment

echo "Testing SMTP authentication on port 587..."

run_tester_interactive python3 /tests/test-smtp-auth.py
