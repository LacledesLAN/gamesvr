#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by TF2 Classic dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified" "./lacledeslan/gamesvr-tf2classified"
chmod +x "./lacledeslan/gamesvr-tf2classified/build.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classified-freeplay" "./lacledeslan/gamesvr-tf2classified-freeplay"
chmod +x "./lacledeslan/gamesvr-tf2classified-freeplay/build.sh"
