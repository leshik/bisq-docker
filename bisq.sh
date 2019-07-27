#!/bin/bash

mkdir -p "$HOME/.vnc"
echo ${VNCPASSWD} | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"

vncserver -geometry 1280x800 :1

DISPLAY=:1 java -Xms256M -Xmx512M \
  --module-path /usr/share/openjfx/lib \
  --add-modules javafx.base \
  --add-modules javafx.controls \
  --add-modules javafx.fxml \
  --add-modules javafx.graphics \
  --add-exports javafx.base/com.sun.javafx.runtime=ALL-UNNAMED \
  --add-exports javafx.base/com.sun.javafx.binding=ALL-UNNAMED \
  --add-exports javafx.base/com.sun.javafx.event=ALL-UNNAMED \
  --add-exports javafx.controls/com.sun.javafx.scene.control.behavior=ALL-UNNAMED \
  --add-exports javafx.controls/com.sun.javafx.scene.control=ALL-UNNAMED \
  --add-exports javafx.graphics/com.sun.javafx.scene=ALL-UNNAMED \
  --add-exports javafx.graphics/com.sun.javafx.stage=ALL-UNNAMED \
  -jar "$HOME/bisq.jar" \
    --maxConnections=6 \
    --msgThrottlePerSec=40 \
    --msgThrottlePer10Sec=200 \
    --numConnectionForBtc=3

vncserver -kill :1
