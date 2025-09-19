#!/bin/bash
set -e

BACKUP_FILE="${BACKUP_DIR}/SCUM_backup_$(date '+%Y%m%d_%H%M%S').zip"

echo "[INFO] Starting backup..."
mkdir -p "${BACKUP_DIR}"

# Zip ทั้งโฟลเดอร์ SCUM
zip -r "${BACKUP_FILE}" "${SERVER_DIR}"

# ลบ backup เก่าเกิน 14 วัน
echo "[INFO] Removing backups older than 14 days..."
find "${BACKUP_DIR}" -type f -name "SCUM_backup_*.zip" -mtime +14 -exec rm -f {} \;

echo "[INFO] Backup finished: ${BACKUP_FILE}"
