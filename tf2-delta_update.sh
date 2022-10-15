#!/bin/bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/gfx-funcs.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/git-funcs.sh"

gfx_section_start "GAMESVR-TF2 (delta update)"

# gamesvr-tf2
git_update "https://github.com/LacledesLAN/gamesvr-tf2.git" "./repos/gamesvr-tf2"
(cd ./repos/gamesvr-tf2 && source ./build-delta.sh)

# gamesvr-tf2-*
source ./.tf2-derivatives.sh

gfx_section_end
