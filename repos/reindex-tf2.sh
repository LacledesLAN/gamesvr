#!/bin/bash
set -e;

#
# Fetch all Laclede's LAN repos used by TF2 dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2" "./lacledeslan/gamesvr-tf2"
git_clone "https://github.com/LacledesLAN/gamesvr-tf2-blindfrag" "./lacledeslan/gamesvr-tf2-blindfrag"
git_clone "https://github.com/LacledesLAN/gamesvr-tf2-freeplay" "./lacledeslan/gamesvr-tf2-freeplay"
