#!/bin/bash
set -e

# ------------------ Environment ------------------
export HOME=${HOME:-/mnt/user/appdata/scum-server}
export WINEPREFIX=${WINEPREFIX:-/wineprefix}
export BACKUP_DIR=${BACKUP_DIR:-/mnt/user/appdata/scum-server/backups}

# ------------------ สร้าง Wine prefix หากยังไม่มี ------------------
if [ ! -d "$WINEPREFIX" ]; then
    echo "[INFO] สร้าง WINE prefix..."
    mkdir -p $WINEPREFIX
    wineboot --init || true
fi

# ------------------ เริ่ม cron สำหรับ backup ------------------
echo "[INFO] เริ่ม cron..."
cron -f -L 15 &

# ------------------ เริ่ม SCUM Server ------------------
echo "[INFO] เริ่ม SCUM Server..."
/mnt/user/appdata/scum-server/start-server.sh
