FROM debian:bullseye-slim

LABEL maintainer="you@example.com"
LABEL description="SCUM Server on Linux via Wine, optimized for Unraid"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV HOME=/serverdata
ENV WINEPREFIX=/wineprefix
ENV STEAMCMD_DIR=/mnt/user/appdata/scum-server/steamcmd
ENV SERVER_DIR=/mnt/user/appdata/scum-server
ENV BACKUP_DIR=/mnt/user/appdata/scum-server/backups
ENV UID=99
ENV GID=100
ENV UMASK=000

# ติดตั้ง dependencies + Wine
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    curl wget unzip ca-certificates xvfb cron zip locales wine64 \
 && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# สร้างโฟลเดอร์สำหรับ SteamCMD, Server และ Backup
RUN mkdir -p ${STEAMCMD_DIR} ${SERVER_DIR} ${BACKUP_DIR} ${WINEPREFIX}

WORKDIR ${HOME}

# คัดลอกสคริปต์
COPY start.sh start-server.sh backup.sh ./
RUN chmod +x start.sh start-server.sh backup.sh

# เปิดพอร์ต SCUM
EXPOSE 7777/udp 7778/udp 7779/udp 7777/tcp 7779/tcp

ENTRYPOINT ["/serverdata/start.sh"]
