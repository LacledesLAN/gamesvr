#!/bin/bash

# Images that derive from 'gamesvr-tf2'

# TODO: Blind Frag

# Freeplay
git_update "https://github.com/LacledesLAN/gamesvr-tf2-freeplay" "./repos/gamesvr-tf2-freeplay"
(cd ./repos/gamesvr-tf2-freeplay && source ./build.sh)
