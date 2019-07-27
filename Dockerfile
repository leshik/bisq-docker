FROM openjdk:10-jre-slim

ENV VNCPASSWD bisq
ENV VERSION 1.1.3-SNAPSHOT
ENV TZ Asia/Bangkok
ENV LANG C.UTF-8
ENV USER bisq
ENV HOME /home/${USER}
ENV SHELL /bin/bash

COPY sources.list /etc/apt/

RUN set -ex ; \
    apt-get update ; \
    apt-get upgrade -y ; \
    apt-get install -y --no-install-recommends \
      openjfx procps \
      tightvncserver x11-xserver-utils dbus-x11 jwm \
      xfonts-base ttf-mscorefonts-installer ; \
    rm -rf /var/lib/apt/lists/* ; \
    useradd -m -s /bin/bash ${USER}

COPY system.jwmrc /etc/jwm/

USER ${USER}
WORKDIR ${HOME}

RUN set -ex ; \
    mkdir -p .local/share/Bisq ; \
    chmod 700 .local/share/Bisq

COPY --chown=${USER} desktop-${VERSION}-all.jar bisq.jar
COPY --chown=${USER} bisq.sh .

EXPOSE 5901
VOLUME ${HOME}/.local/share/Bisq

CMD ${HOME}/bisq.sh
