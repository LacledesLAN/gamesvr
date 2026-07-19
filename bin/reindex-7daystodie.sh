#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-7daystodie" "${REPOS_DIR}/lacledeslan/gamesvr-7daystodie"
chmod +x "${REPOS_DIR}/lacledeslan/gamesvr-7daystodie/build-gamesvr-7daystodie.sh"
