#!/bin/bash

# Images that derive from 'gamesvr-csgo'

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/git-funcs.sh"

# Freeplay
git_update "https://github.com/LacledesLAN/gamesvr-csgo-freeplay" "./repos/gamesvr-csgo-freeplay"
(cd ./repos/gamesvr-csgo-freeplay && source ./build.sh)

# Test
git_update "https://github.com/LacledesLAN/gamesvr-csgo-test" "./repos/gamesvr-csgo-test"
(cd ./repos/gamesvr-csgo-test && source ./build.sh)

# Tourney
git_update "https://github.com/LacledesLAN/gamesvr-csgo-tourney" "./repos/gamesvr-csgo-tourney"
(cd ./repos/gamesvr-csgo-tourney && source ./build.sh)

# Warmod
git_update "https://github.com/LacledesLAN/gamesvr-csgo-warmod" "./repos/gamesvr-csgo-warmod"
(cd ./repos/gamesvr-csgo-warmod && source ./build.sh)
