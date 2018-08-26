FROM ubuntu:16.04

LABEL authors="antespi@gmail.com, joe.g.yates@gmail.com"

ENV \
  MAIL_ADDRESS=address@example.org \
  MAIL_PASS=pass
  MAIL_FS_USER=docker \
  MAIL_FS_HOME=/home/docker \

RUN set -x; \
    apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
      --assume-yes \
      --no-install-recommends \
      dovecot-core \
      dovecot-imapd \
      rsyslog \
      iproute2 \
    && apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y \
    && rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin /var/lib/apt/lists/* \
    && rm -rf /usr/share/man/* && rm -rf /usr/share/doc/* \
    && touch /var/log/auth.log

# Create mail user
RUN adduser $MAIL_FS_USER --home $MAIL_FS_HOME --shell /bin/false --disabled-password --gecos "" \
    && chown -R ${MAIL_FS_USER}: $MAIL_FS_HOME \
    && usermod -aG $MAIL_FS_USER dovecot

COPY dovecot/auth-passwdfile.inc /etc/dovecot/conf.d/
COPY dovecot/??-*.conf /etc/dovecot/conf.d/

ADD entrypoint /usr/local/bin/
RUN chmod a+rx /usr/local/bin/entrypoint

EXPOSE 143

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["tail", "-fn", "0", "/var/log/mail.log"]
