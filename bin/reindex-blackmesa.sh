#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa" "${SCRIPT_DIR}/lacledeslan/gamesvr-blackmesa"
chmod +x "${SCRIPT_DIR}/lacledeslan/gamesvr-blackmesa/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-blackmesa-freeplay"
chmod +x "${SCRIPT_DIR}/lacledeslan/gamesvr-blackmesa-freeplay/build.sh"
