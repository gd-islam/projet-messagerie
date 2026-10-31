FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	postfix \
	dovecot-core \
	dovecot-imapd \
	dovecot-lmtpd \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 25 587 993

CMD ["bash", "-c", "service postfix start && service dovecot start && tail -F /dev/null"]
