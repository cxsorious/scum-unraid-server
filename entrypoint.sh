#!/bin/bash
set -e

# ------------------ Environment ------------------
PARAMS=""
STEAM_CMD="/serverdata/steamcmd/steamcmd.sh"
STEAM_APP_ID="${STEAM_APP_ID:-3792580}"
VALIDATE_CMD=""
SERVER_DIR="/serverdata/SCUM"
BACKUP_DIR="/serverdata/backups"
WINEPREFIX="/wineprefix"
PUID="${PUID:-99}"
PGID="${PGID:-100}"
UMASK="${UMASK:-000}"

# ------------------ Debug info ------------------
echo "[DEBUG] SERVER_DIR=${SERVER_DIR}, STEAM_CMD=${STEAM_CMD}, BACKUP_DIR=${BACKUP_DIR}, WINEPREFIX=${WINEPREFIX}"
echo "[DEBUG] PUID=${PUID}, PGID=${PGID}, UMASK=${UMASK}"

# ------------------ สร้าง user/group ------------------
if ! id -u scum >/dev/null 2>&1; then
    echo "[INFO] สร้าง user scum UID:${PUID} GID:${PGID}"
    groupadd -g ${PGID} scum || true
    useradd -m -u ${PUID} -g ${PGID} -s /bin/bash scum || true
fi

# ------------------ ตั้ง UMASK ------------------
umask $UMASK

# ------------------ สร้างและ fix permissions โฟลเดอร์สำคัญ ------------------
for dir in "$SERVER_DIR" "$BACKUP_DIR" "$WINEPREFIX" "/serverdata/steamcmd"; do
    echo "[INFO] สร้างและตั้งสิทธิ์ $dir"
    mkdir -p "$dir"
    chown -R ${PUID}:${PGID} "$dir"
done

# ------------------ Battleye / Validate ------------------
[ "${SCUM_NO_BATTLEYE,,}" = "true" ] && PARAMS="${PARAMS} -nobattleye"
[ "${VALIDATE,,}" = "true" ] && VALIDATE_CMD="validate"

# ------------------ ตรวจสอบ SteamCMD ------------------
if [ ! -f "$STEAM_CMD" ]; then
    echo "[INFO] SteamCMD ไม่พบ! กำลังดาวน์โหลด..."
    mkdir -p "$(dirname "$STEAM_CMD")"
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
        | tar -xzf - -C "$(dirname "$STEAM_CMD")"
    chown -R ${PUID}:${PGID} "$(dirname "$STEAM_CMD")"
fi

# ------------------ Update SCUM Server ------------------
echo "[INFO] ---Update SCUM Server---"
su scum -c "$STEAM_CMD +@sSteamCmdForcePlatformType windows +force_install_dir $SERVER_DIR +login anonymous +app_update $STEAM_APP_ID $VALIDATE_CMD +quit"

# ------------------ Start SCUM Server ------------------
SERVER_BIN="$SERVER_DIR/SCUM/Binaries/Win64/SCUMServer.exe"
[ ! -f "$SERVER_BIN" ] && { echo "[ERROR] ไม่พบ SCUMServer.exe ใน $SERVER_BIN"; exit 1; }

echo "[INFO] ---Start SCUM Server---"
cd "$(dirname "$SERVER_BIN")"
exec su scum -c "wine SCUMServer.exe -log -port=${SCUM_PORT:-7777} -MaxPlayers=${SCUM_MAX_PLAYERS:-128} $PARAMS"
