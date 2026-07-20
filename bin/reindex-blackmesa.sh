#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/funcs.sh"

mkdir -p "${REPOS_DIR}/gameservers"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa" "${REPOS_DIR}/gameservers/gamesvr-blackmesa"
chmod +x "${REPOS_DIR}/gameservers/gamesvr-blackmesa/build-gamesvr-blackmesa.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay" "${REPOS_DIR}/gameservers/gamesvr-blackmesa-freeplay"
chmod +x "${REPOS_DIR}/gameservers/gamesvr-blackmesa-freeplay/build-gamesvr-blackmesa-freeplay.sh"
