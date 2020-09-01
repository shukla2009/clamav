FROM registry.access.redhat.com/ubi8/ubi:latest
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf update -y
RUN dnf install clamav clamav-update clamd wget -y

RUN adduser clamav
# initial update of av databases
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd
# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

# av configuration update
RUN sed -i 's/#Foreground yes$/Foreground yes/g' /etc/clamd.d/scan.conf && \
    echo "TCPSocket 3310" >> /etc/clamd.d/scan.conf && \
    if [ -n "$HTTPProxyServer" ]; then echo "HTTPProxyServer $HTTPProxyServer" >> /etc/freshclam.conf; fi && \
    if [ -n "$HTTPProxyPort"   ]; then echo "HTTPProxyPort $HTTPProxyPort" >> /etc/freshclam.conf; fi && \
    sed -i 's/#Foreground yes$/Foreground yes/g' /etc/freshclam.conf

# env based configs - will be called by bootstrap.sh
COPY envconfig.sh /

COPY check.sh /

# volume provision
VOLUME ["/var/lib/clamav"]

# port provision
EXPOSE 3310

# av daemon bootstrapping
COPY bootstrap.sh /
CMD ["/bootstrap.sh"]

HEALTHCHECK --start-period=500s CMD /check.sh