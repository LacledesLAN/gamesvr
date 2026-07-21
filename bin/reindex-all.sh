#!/bin/bash
set -e;
set -u;

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="${SCRIPT_DIR}/../repos"
source "${SCRIPT_DIR}/funcs.sh"

mkdir -p "${REPOS_DIR}/gameservers"

#
# Fetch all repos used by Lacledes LAN dedicated gameservers
#

# LL Game Server Repos
chmod +x "${SCRIPT_DIR}/reindex-7daystodie.sh"
"${SCRIPT_DIR}/reindex-7daystodie.sh"

chmod +x "${SCRIPT_DIR}/reindex-blackmesa.sh"
"${SCRIPT_DIR}/reindex-blackmesa.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-cs2d" "${REPOS_DIR}/gameservers/gamesvr-cs2d"
git_clone "https://github.com/LacledesLAN/gamesvr-cs2d-freeplay" "${REPOS_DIR}/gameservers/gamesvr-cs2d-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource" "${REPOS_DIR}/gameservers/gamesvr-cssource"
git_clone "https://github.com/LacledesLAN/gamesvr-cssource-freeplay" "${REPOS_DIR}/gameservers/gamesvr-cssource-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-dods" "${REPOS_DIR}/gameservers/gamesvr-dods"
git_clone "https://github.com/LacledesLAN/gamesvr-dods-freeplay" "${REPOS_DIR}/gameservers/gamesvr-dods-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-factorio" "${REPOS_DIR}/gameservers/gamesvr-factorio"
git_clone "https://github.com/LacledesLAN/gamesvr-fof" "${REPOS_DIR}/gameservers/gamesvr-fof"
git_clone "https://github.com/LacledesLAN/gamesvr-garrysmod" "${REPOS_DIR}/gameservers/gamesvr-garrysmod"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource" "${REPOS_DIR}/gameservers/gamesvr-goldsource"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-cstrike" "${REPOS_DIR}/gameservers/gamesvr-goldsource-cstrike"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-dmc" "${REPOS_DIR}/gameservers/gamesvr-goldsource-dmc"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-hldm" "${REPOS_DIR}/gameservers/gamesvr-goldsource-hldm"
git_clone "https://github.com/LacledesLAN/gamesvr-goldsource-tfc" "${REPOS_DIR}/gameservers/gamesvr-goldsource-tfc"
git_clone "https://github.com/LacledesLAN/gamesvr-hl2dm" "${REPOS_DIR}/gameservers/gamesvr-hl2dm"
git_clone "https://github.com/LacledesLAN/gamesvr-hl2dm-freeplay" "${REPOS_DIR}/gameservers/gamesvr-hl2dm-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-hldms" "${REPOS_DIR}/gameservers/gamesvr-hldms"
git_clone "https://github.com/LacledesLAN/gamesvr-hldms-freeplay" "${REPOS_DIR}/gameservers/gamesvr-hldms-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3" "${REPOS_DIR}/gameservers/gamesvr-ioquake3"
git_clone "https://github.com/LacledesLAN/gamesvr-ioquake3-freeplay" "${REPOS_DIR}/gameservers/gamesvr-ioquake3-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast" "${REPOS_DIR}/gameservers/gamesvr-jk2outcast"
git_clone "https://github.com/LacledesLAN/gamesvr-jk2outcast-freeplay" "${REPOS_DIR}/gameservers/gamesvr-jk2outcast-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft" "${REPOS_DIR}/archived/gamesvr-minecraft"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge1" "${REPOS_DIR}/archived/gamesvr-minecraft-challenge1"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge2" "${REPOS_DIR}/archived/gamesvr-minecraft-challenge2"
git_clone "https://github.com/LacledesLAN/gamesvr-minecraft-challenge3" "${REPOS_DIR}/archived/gamesvr-minecraft-challenge3"
git_clone "https://github.com/LacledesLAN/gamesvr-satisfactory" "${REPOS_DIR}/gameservers/gamesvr-satisfactory"

chmod +x "${SCRIPT_DIR}/reindex-tf2.sh"
"${SCRIPT_DIR}/reindex-tf2.sh"

chmod +x "${SCRIPT_DIR}/reindex-tf2classified.sh"
"${SCRIPT_DIR}/reindex-tf2classified.sh"

git_clone "https://github.com/LacledesLAN/gamesvr-ut99" "${REPOS_DIR}/gameservers/gamesvr-ut99"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004" "${REPOS_DIR}/gameservers/gamesvr-ut2004"
git_clone "https://github.com/LacledesLAN/gamesvr-ut2004-freeplay" "${REPOS_DIR}/gameservers/gamesvr-ut2004-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-valheim" "${REPOS_DIR}/gameservers/gamesvr-valheim"
#git_clone "https://github.com/LacledesLAN/gamesvr-valheim-freeplay" "${REPOS_DIR}/gameservers/gamesvr-valheim-freeplay"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow" "${REPOS_DIR}/gameservers/gamesvr-warsow"
git_clone "https://github.com/LacledesLAN/gamesvr-warsow-freeplay" "${REPOS_DIR}/gameservers/gamesvr-warsow-freeplay"

# LL Documentation & Utility Repos
git_clone "https://github.com/LacledesLAN/get5-cli" "${REPOS_DIR}/lacledeslan/get5-cli"
git_clone "https://github.com/LacledesLAN/README.1ST" "${REPOS_DIR}/lacledeslan/README.1ST"
git_clone "https://github.com/LacledesLAN/ReferenceLogs" "${REPOS_DIR}/lacledeslan/ReferenceLogs"
git_clone "https://github.com/LacledesLAN/SteamCMD" "${REPOS_DIR}/lacledeslan/SteamCMD"

# LL Dependency Mirrors
git_clone "https://github.com/LacledesLAN/amxmodx" "${REPOS_DIR}/lacledeslan/amxmodx"
git_clone "https://github.com/LacledesLAN/sourcemod.linux" "${REPOS_DIR}/lacledeslan/sourcemod.linux"
git_clone "https://github.com/LacledesLAN/sourcemod-configs" "${REPOS_DIR}/lacledeslan/sourcemod-configs"

# 3rd Party Sources
git_clone "https://github.com/alliedmodders/amxmodx" "${REPOS_DIR}/alliedmodders/amxmodx"
git_clone "https://github.com/alliedmodders/metamod-source" "${REPOS_DIR}/alliedmodders/metamod-source"
git_clone "https://github.com/alliedmodders/sourcemod" "${REPOS_DIR}/alliedmodders/sourcemod"
git_clone "https://github.com/splewis/get5" "${REPOS_DIR}/splewis/get5"
