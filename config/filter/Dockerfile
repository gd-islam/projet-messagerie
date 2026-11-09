FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i 's|deb.debian.org|ftp.fr.debian.org|g' /etc/apt/sources.list.d/debian.sources
RUN echo 'Acquire::Retries "5"; Acquire::http::Timeout "20";' > /etc/apt/apt.conf.d/80-network
RUN apt-get update && apt-get install -y --no-install-recommends \
	amavisd-new \
	spamassassin \
	clamav-daemon \
	clamav-freshclam \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN echo "organisation-a.test" > /etc/mailname

RUN usermod -aG amavis clamav \
    && sed -i 's/^LocalSocketGroup clamav$/LocalSocketGroup amavis/' /etc/clamav/clamd.conf \
    && sed -i 's/^LocalSocketMode 666$/LocalSocketMode 660/' /etc/clamav/clamd.conf

COPY 15-content_filter_mode /etc/amavis/conf.d/15-content_filter_mode
COPY 99-local /etc/amavis/conf.d/99-local
COPY start-filter.sh /usr/local/bin/start-filter.sh

RUN chmod +x /usr/local/bin/start-filter.sh

CMD ["/usr/local/bin/start-filter.sh"]
