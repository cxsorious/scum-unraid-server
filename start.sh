#!/bin/bash
set -e

echo "---Ensuring UID: ${UID} and GID: ${GID} match user---"
usermod -u ${UID} root
groupmod -g ${GID} root
usermod -g ${GID} root

echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Taking ownership of data folders---"
chown -R ${UID}:${GID} ${HOME} ${WINEPREFIX} ${STEAMCMD_DIR} ${SERVER_DIR} ${BACKUP_DIR}
chmod -R 770 ${HOME} ${WINEPREFIX} ${STEAMCMD_DIR} ${SERVER_DIR} ${BACKUP_DIR}

echo "---Starting SCUM Server---"
/serverdata/start-server.sh
