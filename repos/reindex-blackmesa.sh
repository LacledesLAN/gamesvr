#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa" "./lacledeslan/gamesvr-blackmesa"
chmod +x "./lacledeslan/gamesvr-blackmesa/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay" "./lacledeslan/gamesvr-blackmesa-freeplay"
chmod +x "./lacledeslan/gamesvr-blackmesa-freeplay/build.sh"
