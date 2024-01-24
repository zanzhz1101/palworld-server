FROM node:14-slim
ARG INSTALL_PATH=/opt/docker-mcsm
ARG TZ=Asia/Shanghai
ENV TZ=${TZ}
RUN sed -i -E 's/http:\/\/deb.debian.org/http:\/\/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt update && apt install -y git
RUN git clone --single-branch -b master --depth 1 https://gitee.com/MCSManager/MCSManager-Daemon-Production $INSTALL_PATH/releases/daemon
RUN cd $INSTALL_PATH/releases/daemon && npm i --production --registry=https://registry.npmmirror.com
WORKDIR $INSTALL_PATH/releases/daemon
CMD node app.js

FROM cm2network/steamcmd:root
RUN sed -i -E 's/http:\/\/deb.debian.org/http:\/\/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt-get update \
    && apt-get install -y --no-install-recommends procps xdg-user-dirs \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSLO https://gh.zanzhz.tk/https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
 && chmod +x supercronic-linux-amd64 \
 && mv supercronic-linux-amd64 "/usr/local/bin/supercronic-linux-amd64" \
 && ln -s "/usr/local/bin/supercronic-linux-amd64" /usr/local/bin/supercronic

USER steam

ENV TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=0 \
    PGID=0 \
    ALWAYS_UPDATE_ON_START=true \
    MAX_PLAYERS=32 \
    MULTITHREAD_ENABLED=true \
    COMMUNITY_SERVER=true \
    RCON_ENABLED=true \
    PUBLIC_IP=10.0.0.1 \
    PUBLIC_PORT=8211 \
    SERVER_NAME=jammsen-docker-generated-###RANDOM### \
    SERVER_DESCRIPTION="Palworld-Dedicated-Server running in Docker by jammsen" \
    SERVER_PASSWORD=serverPasswordHere \
    ADMIN_PASSWORD=adminPasswordHere \
    BACKUP_ENABLED=true \
    BACKUP_CRON_EXPRESSION="0 * * * *"

VOLUME [ "/palworld" ]

EXPOSE 8211/udp
EXPOSE 24444/tcp

ADD --chmod=777 servermanager.sh /servermanager.sh
ADD --chmod=777 backupmanager.sh /backupmanager.sh

CMD ["/servermanager.sh"]
