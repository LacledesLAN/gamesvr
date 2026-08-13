# Specs for active `gamesvr` projects

This directory is the canonical location for specifications shared by active game server repositories. Add and maintain
shared game server requirements in `specs/gamesvr`, rather than duplicating them in repositories under
`repos/gameservers`.

Game server repositories contain the necessary files to build, test, and publish a game server. These repos:

* must start with `gamesvr-` in the repo name.
* build one or more Docker images, with the goal of running a game server for a specific game.
* must have a `README.md` file in the root of the repo.
* must have a `LICENSE` file in the root of the repo.
* must have a `CODE_OF_CONDUCT.md` file in the root of the repo.
* must have a `CONTRIBUTING.md` file in the root of the repo.
* should store any additional documentation or media assets in a `.documentation` folder in the root of the repo.
* must include a test script that complies with the [Test Script Specs](test-scripts.md).

## Game Server 'Levels'

Each repository represents a "level" of the game server.

* Level one represents the stock game server itself, with no modifications, and any necessary dependencies for the game
  server to execute. For example `gamesvr-<game_name>` would be a level one image for the game server `<game_name>`.
  * If a build script is included, it must be named `build-gamesvr-<game_name>.sh` and be located in the root of the
    repo.
  * The test script must be named `test-gamesvr-<game_name>.sh` and be located in the root of the repo.
* Level two represents the game server with custom configuration files/assets, and any necessary dependencies to
  the game server. For example `gamesvr-<game_name>-<scope>` would be a level two image for the game server
  `<game_name>`, with an intended usage of `<scope>`.
  * If a build script is included, it must be named `build-gamesvr-<game_name>-<scope>.sh` and be located in the root of
    the repo.
  * The test script must be named `test-gamesvr-<game_name>-<scope>.sh` and be located in the root of the repo.

## Build Scripts

If a game server is not built in the cloud (e.g. GitHub Actions), it must include a build script that can be run
locally to build, test, and push the Docker image to the cloud. Game server repos that are built in the cloud may
optionally include a build script for local use, following the same conventions.

The top-level orchestration script is part of the `gamesvr` project itself and must be named `build.sh`. Build scripts
inside active game-server repositories must follow the naming requirements under [Game Server 'Levels'](#game-server-levels).
All included build scripts must comply with the [Build Script Specs](build-scripts.md).
