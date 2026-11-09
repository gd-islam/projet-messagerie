#!/usr/bin/env python3
import sys
import smtplib

SERVER = "100.104.64.49"
PORT = 25

SENDER = "relay-test@external.invalid"
RECIPIENT = "recipient@external.invalid"

try:
    with smtplib.SMTP(SERVER, PORT, timeout=15) as smtp:
        smtp.ehlo()

        code, response = smtp.mail(SENDER)
        if code != 250:
            raise RuntimeError(
                f"MAIL FROM rejected: {code} {response!r}"
            )

        code, response = smtp.rcpt(RECIPIENT)
        print(f"External recipient response: {code} {response!r}")

        if 500 <= code < 600:
            print("PASS: Unauthenticated external relay rejected.")
            sys.exit(0)

        smtp.rset()
        raise RuntimeError(
            "External relay was accepted without authentication."
        )

except Exception as error:
    print(f"FAIL: {error}")
    sys.exit(1)
