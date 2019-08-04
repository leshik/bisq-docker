FROM openjdk:10-jre-slim

ARG TARGETPLATFORM

ENV VNCPASSWD bisq
ENV TZ Etc/UTC
ENV LANG C.UTF-8
ENV USER bisq
ENV HOME /home/${USER}
ENV SHELL /bin/bash
# ENV JAVA_OPTS -Xms256M -Xmx512M
# ENV BISQ_DESKTOP_OPTS --maxConnections=6 --msgThrottlePerSec=40 --msgThrottlePer10Sec=200 --numConnectionForBtc=3

COPY sources.list /etc/apt/

RUN set -ex                                     ; \
    apt-get update                              ; \
    apt-get upgrade -y                          ; \
    apt-get install -y --no-install-recommends    \
      openjfx procps                              \
      tightvncserver x11-xserver-utils dbus-x11   \
      jwm xfonts-base ttf-mscorefonts-installer ; \
    rm -rf /var/lib/apt/lists/*                 ; \
    useradd -m -s /bin/bash ${USER}

COPY system.jwmrc /etc/jwm/
COPY --from=bisq:binaries / ${HOME}/lib/
COPY xstartup ${HOME}/.vnc/
COPY bisq-desktop-vnc ${HOME}/

RUN set -ex                                     ; \
    rm $HOME/lib/javafx-*                       ; \
    case $TARGETPLATFORM in                       \
      linux/arm/v7)                               \
        tor_platform=armhf                        \
        ;;                                        \
      linux/arm64)                                \
        tor_platform=arm64                        \
        ;;                                        \
      linux/amd64)                                \
        tor_platform=linux64                      \
        ;;                                        \
      *)                                          \
        echo "$TARGETPLATFORM is not supported" ; \
        exit 1                                    \
        ;;                                        \
    esac                                        ; \
    find $HOME/lib                                \
      -name "tor-binary-*"                        \
      ! -name "*-geoip-*"                         \
      ! -name "*-$tor_platform-*"                 \
      -delete                                   ; \
    mkdir -p $HOME/.local/share/Bisq            ; \
    chmod 700 $HOME/.local/share/Bisq           ; \
    chown -R --reference=$HOME                    \
      $HOME/.local                                \
      $HOME/.vnc                                  \
      $HOME/lib                                   \
      $HOME/bisq-desktop-vnc

EXPOSE 5901
WORKDIR ${HOME}
VOLUME ${HOME}/.local/share/Bisq
USER ${USER}

CMD ["bash", "bisq-desktop-vnc"]
