# Laclede's LAN Game Server Build Script

This repo contains scripts and assets for working with Laclede's LAN game servers.

* It maintains a list of all Laclede's LAN game server repos, and can fetch them to a local machine.
* It can build Laclede's LAN game servers that are not built via Github actions.

## `build.sh`

Builds Laclede's LAN game server that are not built via Github actions.

```shell
./build.sh
```

### Build Targets

> Determines which Docker images will be built. Unless one or more build targets are supplied, all build targets will be chosen.

| Argument          | Base Image              | Derived Images                   |
| :---------------- | :---------------------- | :------------------------------- |
| `--7daystodie`    | `gamesvr-7daystodie`    | n/a                              |
| `--blackmesa`     | `gamesvr-blackmesa`     | `-freeplay`                      |
| `--tf2`           | `gamesvr-tf2`           | `-freeplay`                      |
| `--tf2classified` | `gamesvr-tf2classified` | `-freeplay`                      |

### Build Options

> Directly controls the building of Docker images

| Argument                  | Description |
| :------------------------ | :- |
| `--delta`                 | Build 'base' images, using delta layers, when possible. Use when registry bandwidth is a concern. |
| `--delete-built-image`    | Deletes the Docker image after it has been successfully built. Useful for saving local disk space, when pushing to Docker registries. |
| `--enable-steamcmd-cache` | Enables caching for SteamCMD downloads, which can speed up subsequent builds that require an internet connection. May result in ghost files being added to the images. |
| `--no-docker-cache`       | Disables the Docker build cache, forcing a fresh build of all layers. |
| `--skip-pull`             | Skips pulling the latest base images from the Docker registry. |
| `--skip-tests`            | Skips running any tests defined in the build process. |
| `--skip-push`             | Skips pushing the built Docker images to the registry. |

### Flow Options

| Argument      | Description |
| :------------ | :- |
| `--fast-fail` | Immediately stops the build process upon encountering the first error, rather than continuing with subsequent steps. |
| `--skip-base` | Skips building 'base' images, but builds all 'derived' images. |

## `offline.sh`

Download Laclede's LAN game server assets, so that they can be used offline.

```shell
./offline.sh
```

## General Behaviors

* If a local game server repo is `dirty`, its contents will *not* be updated.
