FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
apt-get -y install --no-install-recommends apt-transport-https ca-certificates tinyproxy add-apt-key debconf-utils iptables expect
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

#Windscribe instructions
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7
RUN echo 'deb https://repo.windscribe.com/ubuntu zesty main' | tee /etc/apt/sources.list.d/windscribe-repo.list
RUN apt-get update && \
apt-get -y install --no-install-recommends windscribe-cli

#Tinyproxy setup
RUN rm /etc/tinyproxy/*
COPY ./conf/tinyproxy/tinyproxy.conf /etc/tinyproxy

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./docker-entrypoint.sh /
EXPOSE 8888
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
