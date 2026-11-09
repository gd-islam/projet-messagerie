#!/usr/bin/env python3
import sys
import ssl
import time
import socket
import smtplib
import imaplib
import getpass
import email
from email.message import EmailMessage

HOST = "mail.organisation-a.test"
IP = "100.104.64.49"
ALICE = "alice@organisation-a.test"
BOB = "bob@organisation-a.test"

mode = sys.argv[1] if len(sys.argv) > 1 else ""

if mode not in ("normal", "spam", "virus"):
    sys.exit("Usage: test-mail-scenarios.py normal|spam|virus")

alice_password = getpass.getpass("Alice password: ")
bob_password = (
    getpass.getpass("Bob password: ")
    if mode in ("normal", "spam")
    else None
)

original_getaddrinfo = socket.getaddrinfo

def resolve(host, *args, **kwargs):
    if host == HOST:
        host = IP
    return original_getaddrinfo(host, *args, **kwargs)

socket.getaddrinfo = resolve

context = ssl.create_default_context(cafile="/tmp/ca.crt")
token = str(int(time.time() * 1000))
subject = f"PROJECT-TEST-{mode.upper()}-{token}"

msg = EmailMessage()
msg["From"] = ALICE
msg["To"] = BOB
msg["Subject"] = subject

if mode == "normal":
    msg.set_content("Normal email delivery integration test.")

elif mode == "spam":
    msg.set_content(
        "SpamAssassin GTUBE test.\n"
        "XJS*C4JDBQADN1.NSBN3*2IDNEN*GTUBE-STANDARD-ANTI-UBE-TEST-EMAIL*C.34X"
    )

elif mode == "virus":
    msg.set_content("EICAR antivirus integration test.")
    msg.add_attachment(
        b"X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*",
        maintype="application",
        subtype="octet-stream",
        filename="eicar.com"
    )

try:
    with smtplib.SMTP(HOST, 587, timeout=15) as smtp:
        smtp.ehlo()
        smtp.starttls(context=context)
        smtp.ehlo()
        smtp.login(ALICE, alice_password)
        smtp.send_message(msg)

    print(f"SMTP accepted message: {subject}")

    if mode == "virus":
        print("EICAR submitted; quarantine must be verified separately.")
        sys.exit(0)

    with imaplib.IMAP4_SSL(
        HOST, 993, ssl_context=context, timeout=15
    ) as imap:
        imap.login(BOB, bob_password)
        imap.select("INBOX")

        # Search directly for the unique subject.
        for attempt in range(15):
            status, data = imap.search(
                None, "HEADER", "Subject", f'"{subject}"'
            )

            if status != "OK":
                raise RuntimeError("Could not search Bob's INBOX")

            message_ids = data[0].split()

            if message_ids:
                latest_id = message_ids[-1]
                status, fetched = imap.fetch(
                    latest_id, "(BODY.PEEK[HEADER])"
                )

                if status != "OK":
                    raise RuntimeError("Could not fetch message headers")

                headers = None
                for item in fetched:
                    if isinstance(item, tuple):
                        headers = email.message_from_bytes(item[1])
                        break

                if headers is None:
                    raise RuntimeError("Message headers were empty")

                if mode == "spam":
                    flag = headers.get("X-Spam-Flag", "").upper()
                    if flag != "YES":
                        raise RuntimeError(
                            f"Message delivered, but X-Spam-Flag is {flag or 'missing'}"
                        )
                    print("PASS: GTUBE detected as spam.")

                else:
                    print("PASS: Normal email delivered to Bob.")

                sys.exit(0)

            time.sleep(2)

    raise RuntimeError("Message not found in Bob's INBOX")

except Exception as error:
    print(f"FAIL: {error}")
    sys.exit(1)
