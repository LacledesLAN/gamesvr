# Laclede's LAN Game Server Build Script

This repo is for building out [Laclede's LAN Game
Servers](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers); particularly those that can't be built in
CI/CD cloud offerings.

## `build.sh`

> Used to build game servers that are too large to be built via Github Actions.

```shell
./build.sh
```

### Option Arguments

| Argument      | Description |
| :------------ | :- |
| `--delta`     | Build deltas where possible (TODO: reason) |
| `--skip-base` | Skips building "base" images. E.g. `gamesvr-X` will get skipped, but `gamesvr-X-**` will get built. |

## Build Targets

> Unless one or more build targets are supplied, all build targets will be chosen

| Argument       | Base Image           | Derived Images                   |
| :------------- | :------------------- | :------------------------------- |
| `--blackmesa`  | `gamesvr-blackmesa`  | `-freeplay`                      |
| `--csgo`       | `gamesvr-csgo`       | `-freeplay`, `-test`, `-tourney` |
| `--tf2`        | `gamesvr-tf2`        | `-blindfrag`, `-freeplay`        |
| `--tf2classic` | `gamesvr-tf2classic` | `-freeplay`                      |

## `offline.sh`

> Use to download assets, so that they can be used offline.

```shell
./offline.sh
```

## General Behaviors

* If a local game server repo is `dirty`, its contents will *not* be updated.
