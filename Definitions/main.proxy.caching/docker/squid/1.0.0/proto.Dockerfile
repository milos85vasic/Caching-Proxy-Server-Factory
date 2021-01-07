FROM fedora:33

ARG PROXY_PORT
ARG PROXY_DOMAIN
ARG PROXY_COUNTRY
ARG PROXY_PROVINCE
ARG PROXY_CITY
ARG PROXY_DEPARTMENT
ARG PROXY_USER
ARG PROXY_USER_PASSWORD

RUN dnf update -y && \
    dnf clean all -y && \
    dnf install findutils -y && \
    dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y squid curl openssl httpd && \
    mkdir -p /var/cache/squid && \
    mkdir -p /etc/squid/passwords

COPY Scripts/entrypoint.sh /usr/local/bin
COPY Scripts/initialize_certificate.sh /usr/local/bin
COPY Configuration/squid.conf /etc/squid/squid.conf
COPY Configuration/openssl.cnf /etc/squid/openssl.cnf

RUN chmod 750 /usr/local/bin/entrypoint.sh && \
    chmod 750 /usr/local/bin/initialize_certificate.sh && \
    htpasswd -c -b /etc/squid/passwords/accounts "$PROXY_USER" "$PROXY_USER_PASSWORD" && \
    chown -R squid:squid /etc/squid/passwords && \
    chmod 440 /etc/squid/passwords

VOLUME /var/cache/squid
VOLUME /var/log/squid
VOLUME /etc/squid/ssl_cert
VOLUME /etc/squid/passwords

EXPOSE $PROXY_PORT

CMD sh /usr/local/bin/initialize_certificate.sh \
    "$PROXY_DOMAIN" "$PROXY_COUNTRY" "$PROXY_PROVINCE" "$PROXY_CITY" "$PROXY_DEPARTMENT" && \
    sh /usr/local/bin/entrypoint.sh