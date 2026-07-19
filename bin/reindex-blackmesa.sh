#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa" "${REPOS_DIR}/lacledeslan/gamesvr-blackmesa"
chmod +x "${REPOS_DIR}/lacledeslan/gamesvr-blackmesa/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay" "${REPOS_DIR}/lacledeslan/gamesvr-blackmesa-freeplay"
chmod +x "${REPOS_DIR}/lacledeslan/gamesvr-blackmesa-freeplay/build.sh"
