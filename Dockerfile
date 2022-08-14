FROM steamcmd/steamcmd

USER 0

ENV DEBIAN_FRONTEND=noninteractive \
  HOME=/opt/app-root \
  WINEPREFIX=/opt/app-root/winedata/WINE64 \
  WINEARCH=win64 \
  DISPLAY=:1.0 \
  APPDATA=/data \
  GAMEDIR=/opt/app-root/game

RUN apt-get update && \
  apt-get install --no-install-recommends -y wine-stable wine32 wine64 xvfb && \
  apt-get clean autoclean  && \
  rm -Rf /var/lib/apt/lists/* && \
  umask 004 && \
  mkdir -p /opt/app-root $APPDATA && \
  chown 1001:0 /opt/app-root $APPDATA

USER 1001

COPY entrypoint.sh /entrypoint.sh

RUN umask 004 && \
  mkdir -p /opt/app-root/winedata/WINE64 && \
  cd /opt/app-root/winedata && \
  winecfg && \
  steamcmd +@sSteamCmdForcePlatformType windows +login anonymous +force_install_dir $GAMEDIR +app_update 556450 validate +quit

WORKDIR /opt/app-root
VOLUME ["$APPDATA"]
EXPOSE 8766/udp 27015/udp 27016/udp

ENTRYPOINT [ "/entrypoint.sh" ]
