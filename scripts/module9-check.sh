#!/usr/bin/env bash
set -u

cd "$(dirname "$0")/.."
mkdir -p docs/preuves
CA="certs/ca/organisation-root-ca.crt"
REPORT="docs/preuves/module9-final-report.txt"

{
  echo "MODULE 9 — FINAL VERIFICATION"
  date -Is

  echo
  echo "===== DOCKER SERVICES ====="
  docker compose ps

  echo
  echo "===== TAILSCALE CONNECTIVITY ====="
  docker exec tailscale-a tailscale ping --c 1 100.79.54.119
  docker exec tailscale-b tailscale ping --c 1 100.104.64.49

  echo
  echo "===== DNS FROM ORGANISATION B ====="
  docker run --rm --network container:tailscale-b alpine:3.20 sh -c '
    apk add --no-cache bind-tools >/dev/null
    dig @100.104.64.49 mail.organisation-a.test A +noall +answer
    dig @100.104.64.49 organisation-a.test MX +noall +answer
    dig @100.104.64.49 organisation-a.test NS +noall +answer
  '

  echo
  echo "===== POSTFIX / DOVECOT ====="
  docker exec mail-a postfix check
  docker exec mail-a service postfix status
  docker exec mail-a service dovecot status
  docker exec mail-a postconf content_filter
  docker exec mail-a postconf smtpd_relay_restrictions

  echo
  echo "===== CERTIFICATE TRUST ====="
  openssl verify -CAfile "$CA" certs/mail-a/mail-a.crt
  openssl x509 -in certs/mail-a/mail-a.crt -noout -subject -dates -ext subjectAltName

  echo
  echo "===== SMTP 587 TLS AND AUTH ====="
  docker run --rm --network container:tailscale-a \
    -v "$CA:/tmp/ca.crt:ro" alpine:3.20 sh -c '
      apk add --no-cache openssl >/dev/null
      printf "EHLO test.local\r\nQUIT\r\n" |
      timeout 10 openssl s_client -quiet -crlf -starttls smtp \
        -connect 127.0.0.1:587 \
        -servername mail.organisation-a.test \
        -CAfile /tmp/ca.crt -verify_return_error 2>&1
    '

  echo
  echo "===== IMAPS 993 TLS ====="
  docker run --rm --network container:tailscale-a \
    -v "$CA:/tmp/ca.crt:ro" alpine:3.20 sh -c '
      apk add --no-cache openssl >/dev/null
      timeout 10 openssl s_client \
        -connect 127.0.0.1:993 \
        -servername mail.organisation-a.test \
        -CAfile /tmp/ca.crt -verify_return_error </dev/null 2>&1
    '

  echo
  echo "===== UNAUTHENTICATED RELAY REJECTION ====="
  docker run --rm --network container:tailscale-b alpine:3.20 sh -c '
    apk add --no-cache busybox-extras >/dev/null
    printf "EHLO node-b\r\nMAIL FROM:<alice@organisation-a.test>\r\nRCPT TO:<relay-check@example.net>\r\nQUIT\r\n" |
    timeout 10 nc 100.104.64.49 25
  '

  echo
  echo "===== SPAM / ANTIVIRUS SERVICES ====="
  docker exec filter-a spamassassin --lint
  docker exec filter-a bash -lc 'ps aux | grep -E "[a]mavis|[c]lamd|[s]pamd"'
  docker exec mail-a postqueue -p

  echo
  echo "===== CLAMAV CLIENT LIMITATION ====="
  docker exec filter-a bash -lc '
    if command -v clamdscan >/dev/null 2>&1; then
      clamdscan --ping 1
    else
      echo "clamdscan unavailable; clamd daemon process was confirmed running."
    fi
  '

  echo
  echo "===== EXISTING FILTER TEST EVIDENCE ====="
  for f in docs/preuves/gtube-spam-detection.txt \
           docs/preuves/eicar-detection-quarantine.txt \
           docs/preuves/eicar-smtp-rejection.txt; do
    echo "--- $f"
    if [ -f "$f" ]; then cat "$f"; else echo "MISSING"; fi
  done

  echo
  echo "===== ARCHITECTURE LIMITATION ====="
  echo "Both Tailscale nodes currently run as containers on the same physical host."
  echo "This does not yet demonstrate two separate physical machines or VMs."

  echo
  echo "===== END OF MODULE 9 REPORT ====="
} 2>&1 | tee "$REPORT"

echo
echo "Report saved to: $REPORT"
