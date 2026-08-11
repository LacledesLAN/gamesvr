#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/funcs.sh"

mkdir -p "${REPOS_DIR}/gameservers"

#
# Fetch all Laclede's LAN repos used by TF2 Classic dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified" "${REPOS_DIR}/gameservers/gamesvr-tf2classified"
require_executable "${REPOS_DIR}/gameservers/gamesvr-tf2classified/build-gamesvr-tf2classified.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified-freeplay" "${REPOS_DIR}/gameservers/gamesvr-tf2classified-freeplay"
require_executable "${REPOS_DIR}/gameservers/gamesvr-tf2classified-freeplay/build-gamesvr-tf2classified-freeplay.sh"
