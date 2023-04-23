#!/bin/bash
set -e;

#
# Fetch all Laclede's LAN repos used by TF2 Classic dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-tf2classic" "./lacledeslan/gamesvr-tf2classic"
git_clone "https://github.com/LacledesLAN/gamesvr-tf2classic-freeplay" "./lacledeslan/gamesvr-tf2classic-freeplay"
