#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"

#
# Fetch all Laclede's LAN repos used by CSGO dedicated servers
#

git_clone "https://github.com/LacledesLAN/gamesvr-csgo" "./lacledeslan/gamesvr-csgo"
git_clone "https://github.com/LacledesLAN/gamesvr-csgo-freeplay" "./lacledeslan/gamesvr-csgo-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-csgo-test" "./lacledeslan/gamesvr-csgo-test"
git_clone "https://github.com/LacledesLAN/gamesvr-csgo-tourney" "./lacledeslan/gamesvr-csgo-tourney"
git_clone "https://github.com/LacledesLAN/gamesvr-csgo-warmod" "./lacledeslan/gamesvr-csgo-warmod"
