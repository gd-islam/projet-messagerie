#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test-common.sh"
check_test_environment
run_tester_interactive python3 /tests/test-mail-scenarios.py spam
