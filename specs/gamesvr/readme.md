# Specs for active `gamesvr` projects

Game server repositories contain the necessary files to build, test, and publish a game server. These repos:

* must start with `gamesvr-` in the repo name.
* build one or more docker images, with the goal of running a game server for a specific game.
* must have a `README.md` file in the root of the repo.
* must have a `LICENSE` file in the root of the repo.
* must have a `CODE_OF_CONDUCT.md` file in the root of the repo.
* must have a `CONTRIBUTING.md` file in the root of the repo.
* should store any additional documentation or media assets in a `.documentation` folder in the root of the repo.
* must have tests to validate the game server functionality.
  * Test shell script(s) must be located in the root of the repo.
  * Tests results should be stored in a `tests` folder in the root of the repo, with all log files ignored via `.gitignore`.

## Game Server 'Levels'

Each repository represents a "level" of the game server.

* Level one represents the stock game server itself, with no modifications, and any necessary dependencies for the game
  server to execute. For example `gamesvr-<game_name>` would be a level one image for the game server `<game_name>`.
  * If a build script is included, it must be named `build-<game_name>.sh` and be located in the root of the repo.
  * The test script must be named `test-<game_name>.sh` and be located in the root of the repo.
* Level two represents the game server with custom configuration files/assets, and any necessary dependencies to
  the game server. For example `gamesvr-<game_name>-<scope>` would be a level two image for the game server
  `<game_name>`, with an intended usage of `<scope>`.
  * If a build script is included, it must be named `build-<game_name>-<scope>.sh` and be located in the root of the repo.
  * The test script must be named `test-<game_name>-<scope>.sh` and be located in the root of the repo.

## Build Scripts

If a game server is not built in the cloud (e.g. GitHub Actions), it must include a build script that can be run
locally to build, test, and push the docker image to the cloud. Game server repos that are built in the cloud may
optionally include a build script for local use, following the same conventions.

* Must be executable shell scripts located in the root of the repo.
* Must work regardless of the current working directory, and should be able to be run from any location on the
  system.
* Must call the related test script(s) as part of the build process before push/publish steps.
* Should create output in markdown format, making it easy to share their output with others.
* Should pass shellcheck validation, and should be linted with `shellcheck` before being committed to the repo.

## Test Scripts

* Every game server repo must include a test script.
* Test scripts are intentionally kept separate and composable so they can be run independently and reused by build scripts.
