# Laclede's LAN Game Server Build Script

This repo is for building out [Laclede's LAN Game
Servers](https://github.com/LacledesLAN/README.1ST/tree/master/GameServers); particularly those that can't be built in
CI/CD cloud offerings.

## `build.sh`

Builds Laclede's LAN game server that are not built via Github actions.

```shell
./build.sh
```

### Option Arguments

| Argument      | Description |
| :------------ | :- |
| `--delta`     | Build 'base' images, using delta layers, when possible. Use when registry bandwidth is a concern. |
| `--skip-base` | Skips building 'base' images, but builds all 'derived' images. |

## Build Targets

> Unless one or more build targets are supplied, all build targets will be chosen

| Argument       | Base Image           | Derived Images                   |
| :------------- | :------------------- | :------------------------------- |
| `--blackmesa`  | `gamesvr-blackmesa`  | `-freeplay`                      |
| `--tf2`        | `gamesvr-tf2`        | `-freeplay`                      |
| `--tf2classic` | `gamesvr-tf2classic` | `-freeplay`                      |

## `offline.sh`

Download Laclede's LAN game server assets, so that they can be used offline.

```shell
./offline.sh
```

## General Behaviors

* If a local game server repo is `dirty`, its contents will *not* be updated.
