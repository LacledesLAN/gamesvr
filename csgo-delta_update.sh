#!/bin/bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/gfx-funcs.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/git-funcs.sh"

gfx_section_start "GAMESVR-CSGO (delta update)"

# gamesvr-csgo
git_update "https://github.com/LacledesLAN/gamesvr-csgo.git" "./repos/gamesvr-csgo"
(cd ./repos/gamesvr-csgo && source ./build-delta.sh)
source ./.csgo-derivatives.sh

gfx_section_end