FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	postfix \
	dovecot-core \
	dovecot-imapd \
	dovecot-lmtpd \
	ca-certificates \
	&& groupadd --gid 5000 vmail \
	&& useradd --uid 5000 --gid vmail \
		--home-dir /var/mail/vhosts \
		--shell /usr/sbin/nologin \
		--no-create-home vmail \
	&& mkdir -p /var/mail/vhosts /var/spool/postfix/private \
	&& chown -R vmail:vmail /var/mail/vhosts \
	&& chmod 0750 /var/mail/vhosts \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 25 587 993

CMD ["bash", "-c", "service postfix start && service dovecot start && tail -F /dev/null"]
