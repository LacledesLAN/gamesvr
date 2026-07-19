#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bin/linux/funcs.sh"


#
# Fetch all repos used by Lacledes LAN dedicated gameservers
#

# LL Game Server Repos
chmod +x "${SCRIPT_DIR}/reindex-7daystodie.sh"
"${SCRIPT_DIR}/reindex-7daystodie.sh"

chmod +x "${SCRIPT_DIR}/reindex-blackmesa.sh"
"${SCRIPT_DIR}/reindex-blackmesa.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-cs2d" "${SCRIPT_DIR}/lacledeslan/gamesvr-cs2d"
git_clone "https://github.com/LacledesLAN/gamesvr-cs2d-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-cs2d-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource" "${SCRIPT_DIR}/lacledeslan/gamesvr-cssource"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-cssource-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-dods" "${SCRIPT_DIR}/lacledeslan/gamesvr-dods"
git_clone "https://github.com/LacledesLAN/gamesvr-dods-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-dods-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-factorio" "${SCRIPT_DIR}/lacledeslan/gamesvr-factorio"
git_clone "https://github.com/LacledesLAN/gamesvr-fof" "${SCRIPT_DIR}/lacledeslan/gamesvr-fof"
git_clone "https://github.com/LacledesLAN/gamesvr-garrysmod" "${SCRIPT_DIR}/lacledeslan/gamesvr-garrysmod"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource" "${SCRIPT_DIR}/lacledeslan/gamesvr-goldsource"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-cstrike" "${SCRIPT_DIR}/lacledeslan/gamesvr-goldsource-cstrike"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-dmc" "${SCRIPT_DIR}/lacledeslan/gamesvr-goldsource-dmc"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-hldm" "${SCRIPT_DIR}/lacledeslan/gamesvr-goldsource-hldm"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-tfc" "${SCRIPT_DIR}/lacledeslan/gamesvr-goldsource-tfc"
git_clone "https://github.com/LacledesLAN/gamesvr-hl2dm" "${SCRIPT_DIR}/lacledeslan/gamesvr-hl2dm"
git_clone "https://github.com/LacledesLAN/gamesvr-hldms-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-hldms-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3" "${SCRIPT_DIR}/lacledeslan/gamesvr-ioquake3"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-ioquake3-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast" "${SCRIPT_DIR}/lacledeslan/gamesvr-jk2outcast"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-jk2outcast-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft" "${SCRIPT_DIR}/lacledeslan/gamesvr-minecraft"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge1" "${SCRIPT_DIR}/lacledeslan/gamesvr-minecraft-challenge1"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge2" "${SCRIPT_DIR}/lacledeslan/gamesvr-minecraft-challenge2"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge3" "${SCRIPT_DIR}/lacledeslan/gamesvr-minecraft-challenge3"
git_clone "https://github.com/LacledesLAN/gamesvr-satisfactory" "${SCRIPT_DIR}/lacledeslan/gamesvr-satisfactory"

chmod +x "${SCRIPT_DIR}/reindex-tf2.sh"
"${SCRIPT_DIR}/reindex-tf2.sh"

chmod +x "${SCRIPT_DIR}/reindex-tf2classified.sh"
"${SCRIPT_DIR}/reindex-tf2classified.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-ut99" "${SCRIPT_DIR}/lacledeslan/gamesvr-ut99"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004" "${SCRIPT_DIR}/lacledeslan/gamesvr-ut2004"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-ut2004-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-valheim" "${SCRIPT_DIR}/lacledeslan/XXgamesvr-valheimXX"
#git_clone "https://github.com/LacledesLAN/gamesvr-valheim-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-valheim-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow" "${SCRIPT_DIR}/lacledeslan/gamesvr-warsow"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow-freeplay" "${SCRIPT_DIR}/lacledeslan/gamesvr-warsow-freeplay"

# LL Documentation & Utility Repos
git_clone "https://github.com/LacledesLAN/get5-cli" "${SCRIPT_DIR}/lacledeslan/get5-cli"
git_clone "https://github.com/LacledesLAN/README.1ST" "${SCRIPT_DIR}/lacledeslan/README.1ST"
git_clone "https://github.com/LacledesLAN/ReferenceLogs" "${SCRIPT_DIR}/lacledeslan/ReferenceLogs"
git_clone "https://github.com/LacledesLAN/SteamCMD" "${SCRIPT_DIR}/lacledeslan/SteamCMD"

# LL Dependency Mirrors
git_clone "https://github.com/LacledesLAN/amxmodx" "${SCRIPT_DIR}/lacledeslan/amxmodx"
git_clone "https://github.com/LacledesLAN/sourcemod.linux" "${SCRIPT_DIR}/lacledeslan/sourcemod.linux"
git_clone "https://github.com/LacledesLAN/sourcemod-configs" "${SCRIPT_DIR}/lacledeslan/sourcemod-configs"

# 3rd Party Sources
git_clone "https://github.com/alliedmodders/amxmodx" "${SCRIPT_DIR}/alliedmodders/amxmodx"
git_clone "https://github.com/alliedmodders/metamod-source" "${SCRIPT_DIR}/alliedmodders/metamod-source"
git_clone "https://github.com/alliedmodders/sourcemod" "${SCRIPT_DIR}/alliedmodders/sourcemod"
git_clone "https://github.com/splewis/get5" "${SCRIPT_DIR}/splewis/get5"
