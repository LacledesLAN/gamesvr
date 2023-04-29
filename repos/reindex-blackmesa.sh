#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by Blackmesa dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa" "./lacledeslan/gamesvr-blackmesa"
git_clone "https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay" "./lacledeslan/gamesvr-blackmesa-freeplay"
