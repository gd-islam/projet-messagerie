# Mail Server Test Results

**Project:** `projet-messagerie`
**Test branch:** `feature/spam-antivirus`
**Test date:** 9 November 2026
**Test runner:** `scripts/test-all.sh`
**Overall result:** **PASS — 11 tests passed, 0 failed**

## 1. Purpose

This report records the results of the integrated test suite for the Organisation A mail-server environment. The tests cover Tailscale reachability, DNS records, encrypted mail protocols, user authentication, message delivery, relay protection, spam detection, and antivirus detection.

## 2. Test environment

| Component | Configuration |
|---|---|
| Organisation A Tailscale IP | `100.104.64.49` |
| Organisation B Tailscale IP | `100.79.54.119` |
| Mail hostname | `mail.organisation-a.test` |
| Mail domain | `organisation-a.test` |
| SMTP | Port 25 |
| SMTP submission | Port 587 with STARTTLS and authentication |
| IMAPS | Port 993 |
| DNS | Organisation A DNS server |
| Mail users used in tests | `alice@organisation-a.test`, `bob@organisation-a.test` |
| Spam test | GTUBE test string |
| Antivirus test | EICAR test file |

**Topology limitation:** The two Tailscale nodes are running in Docker containers on the same physical host. The connectivity test proves communication between the two containerized nodes through Tailscale, but it does not demonstrate connectivity between two physically independent machines or networks.

## 3. Test summary

| # | Test | What was verified | Result |
|---:|---|---|:---:|
| 1 | Tailscale connectivity | Organisation B reached Organisation A; `tailscale ping` received a pong from `100.104.64.49`. | **PASS** |
| 2 | DNS configuration | A record resolved to `100.104.64.49`; MX record pointed to `mail.organisation-a.test`; NS record was present. | **PASS** |
| 3 | SMTP STARTTLS — port 25 | TLS handshake succeeded; certificate chain and hostname verification succeeded; TLS 1.3 negotiated. | **PASS** |
| 4 | SMTP STARTTLS — port 587 | TLS handshake succeeded; certificate chain and hostname verification succeeded; TLS 1.3 negotiated. | **PASS** |
| 5 | IMAPS TLS — port 993 | TLS handshake succeeded; certificate chain and hostname verification succeeded; TLS 1.3 negotiated. | **PASS** |
| 6 | SMTP authentication | Alice authenticated successfully on the submission service. | **PASS** |
| 7 | IMAPS authentication | Alice authenticated successfully and the INBOX mailbox was listed. | **PASS** |
| 8 | Normal email delivery | Alice submitted a test email; Bob authenticated through IMAPS and the unique test message was found in INBOX. | **PASS** |
| 9 | Unauthenticated relay protection | An unauthenticated attempt to send to an external recipient was rejected with `554 5.7.1 Relay access denied`. | **PASS** |
| 10 | Spam detection | The GTUBE test message was identified as spam. The message carried `X-Spam-Flag: YES` and a `[SPAM]` subject prefix. | **PASS** |
| 11 | Antivirus detection | The EICAR test file was detected and the Amavis quarantine file count increased from 9 to 10. | **PASS** |

### Final totals

- **Total tests:** 11
- **Passed:** 11
- **Failed:** 0
- **Success rate:** 100%

## 4. Important observations

### TLS and certificate validation

The three TLS tests completed successfully. The client trusted the project root CA, verified the server certificate chain, and verified the peer hostname `mail.organisation-a.test`. TLS 1.3 was negotiated in the captured test output.

### Authentication and message delivery

SMTP authentication and IMAPS authentication both succeeded for Alice. The end-to-end delivery scenario submitted a uniquely named message from Alice and then located that message in Bob's INBOX.

### Relay protection

The unauthenticated relay test received:

```text
554 5.7.1 <recipient@external.invalid>: Relay access denied
```

This demonstrates that the tested unauthenticated external relay attempt was refused.

### Spam filtering

The GTUBE test message was delivered to the mailbox with spam indicators. The test confirms spam identification and tagging; it does not claim that the message was rejected or discarded.

### Antivirus filtering

The EICAR test message was accepted at SMTP submission, then detected and quarantined. The observed evidence is the increase in quarantine files from 9 to 10 and the successful EICAR detection in the antivirus logs.

**Important distinction:** This test demonstrates antivirus detection and quarantine, not SMTP-time rejection. The test output explicitly reports that SMTP accepted the message before quarantine verification.

## 5. Scope and limitations

The results establish that the listed tests passed in the tested Docker environment. They do not, by themselves, establish all aspects of a production mail deployment.

In particular:

- The two Tailscale nodes share one physical host; independent-host connectivity has not been demonstrated.
- The relay test verifies rejection of an unauthenticated external-recipient attempt. It does not verify successful delivery to a real external mail provider.
- The antivirus test verifies EICAR detection and quarantine, not SMTP-time rejection.
- The test suite does not establish deliverability reputation, public DNS configuration, SPF, DKIM, DMARC, or interoperability with arbitrary external mail providers.
- The tests are point-in-time results and should be rerun after significant configuration changes.

## 6. Reproduction

From the project root, build the test image if it is not already available:

```bash
docker build -t projet-messagerie-tester:1.0 ./scripts/tester
```

Run the complete test suite:

```bash
./scripts/test-all.sh
```

The suite prompts for Alice's password and, for the normal-delivery and spam scenarios, Bob's password. Passwords should be entered only at the interactive prompt and must not be written into the report, scripts, shell history, or Git repository.

The successful run ended with:

```text
Total tests: 11
Passed:      11
Failed:      0
ALL TESTS PASSED.
```

## 7. Conclusion

All 11 tests in the integrated test suite passed. The captured results demonstrate successful Tailscale container connectivity, DNS resolution, TLS on SMTP and IMAPS services, user authentication, internal email delivery, unauthenticated relay rejection, GTUBE spam identification, and EICAR antivirus detection with quarantine.

The topology and scope limitations above should be retained when presenting or evaluating these results.
