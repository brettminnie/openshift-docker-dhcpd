ARG BUILD_IMAGE="almalinux:8-minimal"
FROM ${BUILD_IMAGE}

RUN microdnf update -y && \
    microdnf install -y bind-utils sudo dhcp-server net-tools && \
    microdnf clean all && \
    rm -rf /usr/local/share/man/* && \
    mkdir /config && \
    touch /var/lib/dhcpd/dhcpd.leases && \
    echo -e "Defaults:dhcpd !requiretty" > /etc/sudoers.d/dhcpd &&\
    echo -e "dhcpd ALL=(ALL) NOPASSWD: all" >> /etc/sudoers.d/dhcpd

COPY container_resources/dhcpd.conf /config/

EXPOSE 67/udp

CMD ["/usr/sbin/dhcpd", "-4", "-d", "--no-pid", "-cf", "/config/dhcpd.conf", "-user", "dhcpd", "-group", "dhcpd"]
