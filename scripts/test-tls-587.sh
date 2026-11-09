#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test-common.sh"
check_test_environment

echo "Testing SMTP STARTTLS on port 587..."

run_tester openssl s_client \
    -connect "$SERVER_IP:587" \
    -starttls smtp \
    -servername "$MAIL_HOST" \
    -CAfile /tmp/ca.crt \
    -verify_hostname "$MAIL_HOST" \
    -verify_return_error \
    </dev/null
