#!/bin/bash
set -e

PARAMS=""
STEAM_CMD="${STEAMCMD_DIR}/steamcmd.sh"
STEAM_APP_ID="${STEAM_APP_ID:-3792580}"

# ปิด Battleye ถ้ากำหนด
if [[ "${SCUM_NO_BATTLEYE}" == "true" ]]; then
    PARAMS="${PARAMS} -nobattleye"
fi

# ตรวจสอบ SteamCMD
echo "[INFO] ---Update SteamCMD---"
if [ ! -f "${STEAM_CMD}" ]; then
    echo "[INFO] SteamCMD not found! Downloading..."
    mkdir -p "${STEAMCMD_DIR}"
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
        | tar -xz -C "${STEAMCMD_DIR}"
fi

# อัปเดต SCUM Server
echo "[INFO] ---Update SCUM Server---"
"${STEAM_CMD}" +@sSteamCmdForcePlatformType windows \
            +force_install_dir "${SERVER_DIR}" \
            +login anonymous \
            +app_update "${STEAM_APP_ID}" validate \
            +quit

# เริ่ม server
echo "[INFO] ---Server ready---"
cd "${SERVER_DIR}/SCUM/Binaries/Win64"
echo "[INFO] ---Start SCUM Server---"
wine SCUMServer.exe -log \
    -port=${SCUM_PORT:-7777} \
    -MaxPlayers=${SCUM_MAX_PLAYERS:-64} \
    ${PARAMS}
