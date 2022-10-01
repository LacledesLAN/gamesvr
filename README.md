# Laclede's LAN Game Server Build Script

This repo is for building out [Laclede's LAN Game
Servers](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers); particularly those that can't be built in
CI/CD cloud offerings.

## Build Scripts

| Script                   | Purpose                                                                                |
| ------------------------ | -------------------------------------------------------------------------------------- |
| `./csgo-delta_update.sh` | Update and push `gamesvr-csgo`, rebuild and push all other CSGO-related Docker images. |
| `./csgo-full_update.sh`  | Rebuild and push all CSGO-related Docker images.                                       |

## Utility Scripts

| Script         | Purpose                                  |
| -------------- | ---------------------------------------- |
| `./reindex.sh` | Download/update all LL game server repos |

## General Behaviors

* If a local game server repo is `dirty`, its contents will *not* be updated.
