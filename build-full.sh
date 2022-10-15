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
docker build --rm ./repos/gamesvr-tf2 -f ./repos/gamesvr-tf2/linux.Dockerfile --no-cache --tag lacledeslan/gamesvr-tf2:base --tag lacledeslan/gamesvr-tf2:latest
docker run -it --rm lacledeslan/gamesvr-tf2 ./ll-tests/gamesvr-tf2.sh;
docker push lacledeslan/gamesvr-tf2:base
docker push lacledeslan/gamesvr-tf2:latest

docker build --rm ./repos/gamesvr-tf2-blindfrag -f ./repos/gamesvr-tf2-blindfrag/linux.Dockerfile --tag lacledeslan/gamesvr-tf2-blindfrag:latest
docker run -it --rm lacledeslan/gamesvr-tf2-blindfrag ./ll-tests/gamesvr-tf2-blindfrag.sh;
docker push lacledeslan/gamesvr-tf2-blindfrag:latest

docker build --rm ./repos/gamesvr-tf2-freeplay -f ./repos/gamesvr-tf2-freeplay/linux.Dockerfile --tag lacledeslan/gamesvr-tf2-freeplay:latest
docker run -it --rm lacledeslan/gamesvr-tf2-freeplay ./ll-tests/gamesvr-tf2-freeplay.sh;
docker push lacledeslan/gamesvr-tf2-freeplay:latest
