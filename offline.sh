#!/bin/bash
set -e;
set -u;

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/funcs.sh"

ui_header1 "Pull common Docker images"

docker pull debian:bullseye-slim;
docker pull debian:buster-slim;
docker pull debian:stable-slim;
docker pull debian:stretch-slim;
docker pull lacledeslan/steamcmd:latest;
docker pull lacledeslan/steamcmd:linux;


ui_header1 "Cloning Laclede's LAN gamesvr repos (and related repos)";

(cd ./repos/ && source reindex-all.sh)
