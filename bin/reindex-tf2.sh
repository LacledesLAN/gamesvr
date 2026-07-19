#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by TF2 dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2" "${SCRIPT_DIR}/lacledeslan/gamesvr-tf2"
chmod +x "./lacledeslan/gamesvr-tf2/build-gamesvr-tf2.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-tf2-freeplay"
chmod +x "./lacledeslan/gamesvr-tf2-freeplay/build-gamesvr-tf2-freeplay.sh"
