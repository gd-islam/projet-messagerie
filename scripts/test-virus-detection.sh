#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/test-common.sh"
check_test_environment

QUARANTINE="/var/lib/amavis/virusmails"

count_quarantine() {
    docker exec filter-a sh -c \
        "find '$QUARANTINE' -type f 2>/dev/null | wc -l" \
        | tr -d ' '
}

echo "===== VIRUS DETECTION TEST ====="

before=$(count_quarantine)
echo "Quarantine before test: $before"

if run_tester_interactive python3 /tests/test-mail-scenarios.py virus; then
    submission=0
else
    submission=$?
fi

after=$(count_quarantine)
echo "Quarantine after test:  $after"

if (( after > before )); then
    echo "PASS: EICAR detected and quarantined."
elif (( submission != 0 )); then
    echo "FAIL: Submission failed and quarantine did not increase."
    exit 1
else
    echo "FAIL: No new quarantined file detected."
    exit 1
fi
