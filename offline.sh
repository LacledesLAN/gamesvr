#!/bin/bash
set -euo pipefail

GAMESVR_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${GAMESVR_ROOT}/bin/funcs.sh"
require_command docker

ui_header1 "Pull common Docker images"

docker pull debian:stable-slim;
docker pull debian:stretch-slim;
docker pull debian:trixie-slim;
docker pull debian:bookworm-slim;
docker pull lacledeslan/steamcmd:latest;


ui_header1 "Cloning Laclede's LAN gamesvr repos (and related repos)";

"${GAMESVR_ROOT}/bin/reindex-all.sh"
