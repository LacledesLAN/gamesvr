#!/bin/bash

docker pull lacledeslan/steamcmd;
docker pull debian:buster-slim;
docker pull debian:bullseye-slim;

# Blackmesa
docker build --rm ./repos/gamesvr-blackmesa -f ./repos/gamesvr-blackmesa/linux.Dockerfile --no-cache --tag lacledeslan/gamesvr-blackmesa:base --tag lacledeslan/gamesvr-blackmesa:latest
docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh;
docker push lacledeslan/gamesvr-blackmesa:base
docker push lacledeslan/gamesvr-blackmesa:latest

docker build --rm ./repos/gamesvr-blackmesa-freeplay -f ./repos/gamesvr-blackmesa-freeplay/linux.Dockerfile --tag lacledeslan/gamesvr-blackmesa-freeplay:latest
docker run -it --rm lacledeslan/gamesvr-blackmesa-freeplay ./ll-tests/gamesvr-blackmesa-freeplay.sh;
docker push lacledeslan/gamesvr-blackmesa-freeplay:latest


# CSGO
docker build --rm ./repos/gamesvr-csgo -f ./repos/gamesvr-csgo/linux.Dockerfile --no-cache --tag lacledeslan/gamesvr-csgo:base --tag lacledeslan/gamesvr-csgo:latest
docker run -it --rm lacledeslan/gamesvr-csgo ./ll-tests/gamesvr-csgo.sh;
docker push lacledeslan/gamesvr-csgo:base
docker push lacledeslan/gamesvr-csgo:latest


docker build --rm ./repos/gamesvr-csgo-freeplay -f ./repos/gamesvr-csgo-freeplay/linux.Dockerfile --tag lacledeslan/gamesvr-csgo-freeplay:latest
docker run --rm lacledeslan/gamesvr-csgo-freeplay ./ll-tests/gamesvr-csgo-freeplay.sh;
docker push lacledeslan/gamesvr-csgo-freeplay:latest

docker build --rm ./repos/gamesvr-csgo-test -f ./repos/gamesvr-csgo-test/linux.Dockerfile --tag lacledeslan/gamesvr-csgo-test:latest
docker run -it --rm lacledeslan/gamesvr-csgo-test ./ll-tests/gamesvr-csgo-test.sh;
docker push lacledeslan/gamesvr-csgo-test:latest

# TODOs: tourney, warmod


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
