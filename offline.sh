#!/bin/bash
set -u;

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/funcs.sh"

ui_section_start "Pull common Docker images"

#TODO: pull commonly used Docker images

ui_section_start "Cloning Laclede's LAN gamesvr repos (and related repos)";

(cd ./repos/ && source reindex-all.sh)
