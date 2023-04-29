#!/bin/bash
set -e;
set -u;

source "../bin/linux/funcs.sh"
#
# Fetch all repos used by Lacledes LAN dedicated gameservers
#

# LL Game Server Repos
git_clone "https://github.com/LacledesLAN/gamesvr-7daystodie" "./lacledeslan/gamesvr-7daystodie"
git_clone "https://github.com/LacledesLAN/gamesvr-7daystodie-freeplay" "./lacledeslan/gamesvr-7daystodie-freeplay"
./reindex-blackmesa.sh
./reindex-csgo.sh
git_clone "https://github.com/LacledesLAN/gamesvr-csgo-warmod" "./lacledeslan/gamesvr-csgo-warmod"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource" "./lacledeslan/gamesvr-cssource"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource-freeplay" "./lacledeslan/gamesvr-cssource-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-dods" "./lacledeslan/gamesvr-dods"
git_clone "https://github.com/LacledesLAN/gamesvr-dods-freeplay" "./lacledeslan/gamesvr-dods-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-factorio" "./lacledeslan/gamesvr-factorio"
git_clone "https://github.com/LacledesLAN/gamesvr-fof" "./lacledeslan/gamesvr-fof"
git_clone "https://github.com/LacledesLAN/gamesvr-garrysmod" "./lacledeslan/gamesvr-garrysmod"
git_clone "https://github.com/LacledesLAN/gamesvr-gesource" "./lacledeslan/gamesvr-gesource"
git_clone "https://github.com/LacledesLAN/gamesvr-gesource-freeplay" "./lacledeslan/gamesvr-gesource-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource" "./lacledeslan/gamesvr-goldsource"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-cstrike" "./lacledeslan/gamesvr-goldsource-cstrike"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-dmc" "./lacledeslan/gamesvr-goldsource-dmc"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-hldm" "./lacledeslan/gamesvr-goldsource-hldm"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-tfc" "./lacledeslan/gamesvr-goldsource-tfc"
git_clone "https://github.com/LacledesLAN/gamesvr-hl2dm" "./lacledeslan/gamesvr-hl2dm"
git_clone "https://github.com/LacledesLAN/gamesvr-hldms-freeplay" "./lacledeslan/gamesvr-hldms-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3" "./lacledeslan/gamesvr-ioquake3"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3-freeplay" "./lacledeslan/gamesvr-ioquake3-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast" "./lacledeslan/gamesvr-jk2outcast"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast-freeplay" "./lacledeslan/gamesvr-jk2outcast-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft" "./lacledeslan/gamesvr-minecraft"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge1" "./lacledeslan/gamesvr-minecraft-challenge1"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge2" "./lacledeslan/gamesvr-minecraft-challenge2"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge3" "./lacledeslan/gamesvr-minecraft-challenge3"
git_clone "https://github.com/LacledesLAN/gamesvr-satisfactory" "./lacledeslan/gamesvr-satisfactory"
git_clone "https://github.com/LacledesLAN/gamesvr-quake2" "./lacledeslan/gamesvr-quake2"
git_clone "https://github.com/LacledesLAN/gamesvr-quake2-freeplay" "./lacledeslan/gamesvr-quake2-freeplay"
./reindex-tf2.sh
./reindex-tf2classic.sh
git_clone "https://github.com/LacledesLAN/gamesvr-ut99" "./lacledeslan/gamesvr-ut99"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004" "./lacledeslan/gamesvr-ut2004"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004-freeplay" "./lacledeslan/gamesvr-ut2004-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-valheim" "./lacledeslan/XXgamesvr-valheimXX"
#git_clone "https://github.com/LacledesLAN/gamesvr-valheim-freeplay" "./lacledeslan/gamesvr-valheim-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow" "./lacledeslan/gamesvr-warsow"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow-freeplay" "./lacledeslan/gamesvr-warsow-freeplay"

# LL Documentation & Utility Repos
git_clone "https://github.com/LacledesLAN/get5-cli" "./lacledeslan/get5-cli"
git_clone "https://github.com/LacledesLAN/README.1ST" "./lacledeslan/README.1ST"
git_clone "https://github.com/LacledesLAN/ReferenceLogs" "./lacledeslan/ReferenceLogs"
git_clone "https://github.com/LacledesLAN/SteamCMD" "./lacledeslan/SteamCMD"

# LL Dependency Mirrors
git_clone "https://github.com/LacledesLAN/amxmodx" "./lacledeslan/amxmodx"
git_clone "https://github.com/LacledesLAN/sourcemod.linux" "./lacledeslan/sourcemod.linux"
git_clone "https://github.com/LacledesLAN/sourcemod.windows" "./lacledeslan/sourcemod.windows"
git_clone "https://github.com/LacledesLAN/sourcemod-configs" "./lacledeslan/sourcemod-configs"

# 3rd Party Sources
git_clone "https://github.com/alliedmodders/amxmodx" "./alliedmodders/amxmodx"
git_clone "https://github.com/alliedmodders/metamod-source" "./alliedmodders/metamod-source"
git_clone "https://github.com/alliedmodders/sourcemod" "./alliedmodders/sourcemod"
git_clone "https://github.com/splewis/get5" "./splewis/get5"
