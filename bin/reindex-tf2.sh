#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/funcs.sh"
require_command git

mkdir -p "${REPOS_DIR}/gameservers"

#
# Fetch all Laclede's LAN repos used by TF2 dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2" "${REPOS_DIR}/gameservers/gamesvr-tf2"
require_executable "${REPOS_DIR}/gameservers/gamesvr-tf2/build-gamesvr-tf2.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2-freeplay" "${REPOS_DIR}/gameservers/gamesvr-tf2-freeplay"
require_executable "${REPOS_DIR}/gameservers/gamesvr-tf2-freeplay/build-gamesvr-tf2-freeplay.sh"
