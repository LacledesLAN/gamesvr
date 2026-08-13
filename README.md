# Laclede's LAN Game Server Build Script

This repo contains scripts and assets for working with Laclede's LAN game servers.

* It maintains a list of all Laclede's LAN game server repos, and can fetch them to a local machine.
* It can build Laclede's LAN game servers that are not built via GitHub actions.

## Repository Layout

Shared specifications for all active game server repositories live in [`specs/gamesvr`](specs/gamesvr/readme.md).
Add and maintain game server specifications there, not in an individual repository under `repos/gameservers`.
Active game server repositories are checked out under `repos/gameservers` and must follow those specifications.

## VS Code Workspace

Open `gamesvr.code-workspace` in VS Code to work with this project and all repositories under
`repos/lacledeslan`, `repos/alliedmodders`, and `repos/splewis` in one window. Each nested Git repository is
detected independently in the Source Control view, so branches, commits, pulls, and pushes remain separate.

Run `./bin/reindex-all.sh` before opening the workspace to fetch any missing repositories. Repositories cloned
later are detected automatically.

## `build.sh`

Builds Laclede's LAN game server that are not built via GitHub actions.

```shell
./build.sh
```

### Build Targets

> Determines which Docker images will be built. Unless one or more build targets are supplied, all build targets will be
chosen.

| Argument          | Base Image              | Derived Images |
| :---------------- | :---------------------- | :------------- |
| `--7daystodie`    | `gamesvr-7daystodie`    | n/a            |
| `--blackmesa`     | `gamesvr-blackmesa`     | `-freeplay`    |
| `--tf2`           | `gamesvr-tf2`           | `-freeplay`    |
| `--tf2classified` | `gamesvr-tf2classified` | `-freeplay`    |

### Build Options

> Directly controls the building of Docker images

| Argument                  | Description                                                                                                  |
| :------------------------ | :----------------------------------------------------------------------------------------------------------- |
| `--delta`                 | Build 'base' images, using delta layers, when possible. Use when registry bandwidth is a concern.            |
| `--delete-built-image`    | Deletes the Docker image after a successful build to save local disk space when pushing to registries.       |
| `--enable-steamcmd-cache` | Enables SteamCMD download caching to speed up subsequent builds (may introduce ghost files into the images). |
| `--disable-docker-cache`       | Disables the Docker build cache, forcing a fresh build of all layers.                                        |
| `--skip-pull`             | Skips pulling the latest base images from the Docker registry.                                               |
| `--skip-tests`            | Skips running any tests defined in the build process.                                                        |
| `--skip-push`             | Skips pushing the built Docker images to the registry.                                                       |

### Flow Options

| Argument      | Description                                                    |
| :------------ | :------------------------------------------------------------- |
| `--fast-fail` | Immediately stops the entire build process on the first error. |
| `--skip-base` | Skips building 'base' images, but builds all 'derived' images. |

## `offline.sh`

Download Laclede's LAN game server assets, so that they can be used offline.

```shell
./offline.sh
```

## Repository Reindex Output

Each repository operation is emitted as a Markdown `### organization/repository` section. The section reports
whether the local directory was created and cloned, was already up to date, or was fast-forwarded. It includes
the upstream branch and revision, together with commit and tracked-file counts or fast-forward change statistics.

## General Behaviors

* If a local game server repo has uncommitted changes, reindexing stops with an error and does not update that repository.
