#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/funcs.sh"

#
# Fetch all Laclede's LAN repos used by TF2 Classic dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified" "${REPOS_DIR}/gameservers/gamesvr-tf2classified"
chmod +x "${REPOS_DIR}/gameservers/gamesvr-tf2classified/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified-freeplay" "${REPOS_DIR}/gameservers/gamesvr-tf2classified-freeplay"
chmod +x "${REPOS_DIR}/gameservers/gamesvr-tf2classified-freeplay/build.sh"
