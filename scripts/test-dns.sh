#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/test-common.sh"
check_test_environment

DNS_SERVER="100.104.64.49"
DOMAIN="organisation-a.test"
MAIL_HOST="mail.organisation-a.test"

echo "===== DNS CONFIGURATION TEST ====="

echo "--- A record ---"
A_RECORD=$(run_tester dig @"$DNS_SERVER" "$MAIL_HOST" A +short)
echo "$A_RECORD"

if ! grep -Fxq "100.104.64.49" <<< "$A_RECORD"; then
    echo "FAIL: Incorrect or missing mail server A record."
    exit 1
fi

echo "--- MX record ---"
MX_RECORD=$(run_tester dig @"$DNS_SERVER" "$DOMAIN" MX +short)
echo "$MX_RECORD"

if ! grep -q "$MAIL_HOST" <<< "$MX_RECORD"; then
    echo "FAIL: Missing or incorrect MX record."
    exit 1
fi

echo "--- NS record ---"
NS_RECORD=$(run_tester dig @"$DNS_SERVER" "$DOMAIN" NS +short)
echo "$NS_RECORD"

if [[ -z "$NS_RECORD" ]]; then
    echo "FAIL: No NS record found."
    exit 1
fi

echo "PASS: A, MX and NS records verified."
