#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-7daystodie" "${SCRIPT_DIR}/lacledeslan/gamesvr-7daystodie"
chmod +x "${SCRIPT_DIR}/lacledeslan/gamesvr-7daystodie/build-gamesvr-7daystodie.sh"
