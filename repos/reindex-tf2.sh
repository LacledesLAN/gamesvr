#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by TF2 dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2" "./lacledeslan/gamesvr-tf2"
chmod +x "./lacledeslan/gamesvr-tf2/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2-freeplay" "./lacledeslan/gamesvr-tf2-freeplay"
chmod +x "./lacledeslan/gamesvr-tf2-freeplay/build.sh"
