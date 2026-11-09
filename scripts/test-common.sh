#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

TEST_IMAGE="projet-messagerie-tester:1.0"
SERVER_IP="100.104.64.49"
MAIL_HOST="mail.organisation-a.test"
MAIL_USER="alice@organisation-a.test"
CA_CERT="$SCRIPT_DIR/../certs/ca/organisation-root-ca.crt"

check_test_environment() {
    command -v docker >/dev/null 2>&1 || {
        echo "ERROR: Docker is not installed or unavailable."
        exit 1
    }

    [[ -f "$CA_CERT" ]] || {
        echo "ERROR: CA certificate not found: $CA_CERT"
        exit 1
    }

    docker image inspect "$TEST_IMAGE" >/dev/null 2>&1 || {
        echo "ERROR: Test image missing. Build it with:"
        echo "docker build -t $TEST_IMAGE ./scripts/tester"
        exit 1
    }

    docker inspect tailscale-b >/dev/null 2>&1 || {
        echo "ERROR: Container tailscale-b is not available."
        exit 1
    }
}

run_tester() {
    docker run --rm \
        --network container:tailscale-b \
        -v "$CA_CERT:/tmp/ca.crt:ro" \
        -v "$SCRIPT_DIR:/tests:ro" \
        "$TEST_IMAGE" "$@"
}

run_tester_interactive() {
    docker run --rm -it \
        --network container:tailscale-b \
        -v "$CA_CERT:/tmp/ca.crt:ro" \
        -v "$SCRIPT_DIR:/tests:ro" \
        "$TEST_IMAGE" "$@"
}
