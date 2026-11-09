#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

tests=(
    test-connectivity.sh
    test-dns.sh
    test-tls-25.sh
    test-tls-587.sh
    test-tls-993.sh
    test-smtp-auth.sh
    test-imaps-auth.sh
    test-email-delivery.sh
    test-mail-relay.sh
    test-spam-detection.sh
    test-virus-detection.sh
)

passed=0
failed=0

echo "=========================================="
echo "       MAIL SERVER TEST SUITE"
echo "=========================================="

for test in "${tests[@]}"; do
    echo
    echo "------------------------------------------"
    echo "RUNNING: $test"
    echo "------------------------------------------"

    if bash "$SCRIPT_DIR/$test"; then
        echo "RESULT: PASS - $test"
        ((passed+=1))
    else
        echo "RESULT: FAIL - $test"
        ((failed+=1))
    fi
done

echo
echo "=========================================="
echo "             FINAL SUMMARY"
echo "=========================================="
echo "Total tests: ${#tests[@]}"
echo "Passed:      $passed"
echo "Failed:      $failed"
echo "=========================================="

if (( failed > 0 )); then
    exit 1
fi

echo "ALL TESTS PASSED."
