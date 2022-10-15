#!/bin/bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/gfx-funcs.sh"
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/git-funcs.sh"

gfx_allthethings


# Update repos
source ./reindex.sh


# Pull common base images
source ./pull-base-images.sh


# Blackmesa
docker build --rm ./repos/gamesvr-blackmesa -f ./repos/gamesvr-blackmesa/linux.Dockerfile --no-cache --tag lacledeslan/gamesvr-blackmesa:base --tag lacledeslan/gamesvr-blackmesa:latest
docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh;
docker push lacledeslan/gamesvr-blackmesa:base
docker push lacledeslan/gamesvr-blackmesa:latest

docker build --rm ./repos/gamesvr-blackmesa-freeplay -f ./repos/gamesvr-blackmesa-freeplay/linux.Dockerfile --tag lacledeslan/gamesvr-blackmesa-freeplay:latest
docker run -it --rm lacledeslan/gamesvr-blackmesa-freeplay ./ll-tests/gamesvr-blackmesa-freeplay.sh;
docker push lacledeslan/gamesvr-blackmesa-freeplay:latest


# CSGO
source ./csgo-full_update.sh

#TF2
source ./tf2-full_update.sh
