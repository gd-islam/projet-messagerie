#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

tests=(
    test-tls-25.sh
    test-tls-587.sh
    test-tls-993.sh
    test-smtp-auth.sh
    test-imaps-auth.sh
)

passed=0
failed=0

echo "=================================="
echo "   MAIL SERVER TEST SUITE"
echo "=================================="

for test in "${tests[@]}"; do
    echo
    echo "----------------------------------"
    echo "Running: $test"
    echo "----------------------------------"

    if "$SCRIPT_DIR/$test"; then
        echo "RESULT: PASS"
        ((passed+=1))
    else
        echo "RESULT: FAIL"
        ((failed+=1))
    fi
done

echo
echo "=================================="
echo "           FINAL REPORT"
echo "=================================="
echo "Passed: $passed"
echo "Failed: $failed"
echo "=================================="

if (( failed > 0 )); then
    exit 1
fi
