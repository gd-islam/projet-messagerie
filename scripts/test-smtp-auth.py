import smtplib
import ssl
import getpass
import socket
import sys

hostname = "mail.organisation-a.test"
server_ip = "100.104.64.49"
username = "alice@organisation-a.test"

# Resolve the hostname to the server's Tailscale IP.
original_getaddrinfo = socket.getaddrinfo

def custom_getaddrinfo(host, *args, **kwargs):
    if host == hostname:
        host = server_ip
    return original_getaddrinfo(host, *args, **kwargs)

socket.getaddrinfo = custom_getaddrinfo

password = getpass.getpass("Alice password: ")
context = ssl.create_default_context(cafile="/tmp/ca.crt")

try:
    with smtplib.SMTP(hostname, 587, timeout=10) as server:
        server.ehlo()
        server.starttls(context=context)
        server.ehlo()
        server.login(username, password)

        print("PASS: SMTP authentication accepted.")

except Exception as error:
    print("FAIL: SMTP authentication failed:", error)
    sys.exit(1)
