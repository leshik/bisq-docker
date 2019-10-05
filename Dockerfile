FROM debian:buster-slim

ARG version
ARG jar_lib_archive

ENV LANG C.UTF-8
ENV TZ Etc/UTC
ENV USER bisq
ENV HOME /var/lib/${USER}
ENV SHELL /bin/bash

COPY sources.list /etc/apt/
COPY system.jwmrc /etc/jwm/
COPY xstartup ${HOME}/.vnc/
COPY vncrc ${HOME}/.vncrc

RUN apt-get update && apt-get upgrade -y \
 && mkdir -p /usr/share/man/man1 \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o Dpkg::Options::="--force-confold" \
      tightvncserver x11-xserver-utils dbus-x11 jwm xfonts-base fonts-liberation2 adwaita-icon-theme \
      procps wget gpg gpg-agent unzip openjdk-11-jre openjfx \
 && rm -rf /var/lib/apt/lists/*

COPY bisq-desktop-vnc ${HOME}/

RUN wget -q -P /tmp https://github.com/bisq-network/bisq/releases/download/v${version}/${jar_lib_archive} \
 && wget -q -P /tmp https://github.com/bisq-network/bisq/releases/download/v${version}/${jar_lib_archive}.asc \
 && wget -q -O - https://bisq.network/pubkey/29CDFD3B.asc | gpg --import \
 && gpg --digest-algo SHA256 --verify /tmp/${jar_lib_archive}.asc \
 && unzip -d /usr/share/bisq /tmp/${jar_lib_archive} \
 && rm -rf /usr/share/bisq/lib/javafx-* /usr/share/bisq/lib/tor-binary-* /tmp/* \
 && useradd -r -g nogroup -d ${HOME} -s ${SHELL} ${USER} \
 && mkdir ${HOME}/data \
 && chown -R ${USER}:nogroup ${HOME}

USER ${USER}
WORKDIR ${HOME}

CMD ["bash", "bisq-desktop-vnc"]
