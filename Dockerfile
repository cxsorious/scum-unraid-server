FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ------------------ ติดตั้ง dependency + Wine ------------------
# (ส่วนนี้คงไว้ตามเดิม)
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       curl wget unzip ca-certificates gnupg software-properties-common xvfb zip locales sudo \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ------------------ symlink wine64 ------------------
RUN ln -sf /usr/bin/wine64 /usr/bin/wine

WORKDIR /serverdata

# ------------------ คัดลอก entrypoint ------------------
COPY start-server.sh ./
RUN chmod +x start-server.sh

# ------------------ เป็นการรันโดย root เพื่อให้ start-server.sh จัดการ user/group เอง ------------------
CMD ["./start-server.sh"]