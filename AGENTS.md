# Instructions for Agents

## `gamesvr` Repos

* All gamesvr repos:
  * build one or more docker images, with the goal of running a game server for a specific game.
  * must have a `README.md` file in the root of the repo.
  * must have a `LICENSE` file in the root of the repo.
  * must have a `CODE_OF_CONDUCT.md` file in the root of the repo.
  * must have a `CONTRIBUTING.md` file in the root of the repo.
  * should store any additional documentation or media assets in a `.documentation` folder in the root of the repo.
  * should have tests to validate the game server functionality, and those tests should be stored in a `tests` folder
    in the root of the repo.

If game server is too large to build in the cloud, it:

* must include a build script that can be run locally to build, test, and push the docker image to the cloud.

### Levels

* Level zero represents the upstream, base image for the game server. It should be a minimal image that contains only
  the necessary dependencies to run the game server. It should not contain any game-specific files or configurations.
* Level one represents the game server itself, with stock configuration files/asseets, and any necessary dependencies to
  the game server.  For example `gamesvr-<game_name>` would be a level one image for the game server `<game_name>`.
  * The build script must be named `build-<game_name>.sh` and be located in the root of the repo.
* Level two represents the game server with custom configuration files/assets, and any necessary dependencies to
  the game server.  For example `gamesvr-<game_name>-<scope>` would be a level two image for the game server
  `<game_name>`, with an intended usage of `<scope>`.
  * The build script must be named `build-<game_name>-<scope>.sh` and be located in the root of the repo.
