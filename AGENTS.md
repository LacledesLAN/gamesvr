# Instructions for Agents

## Game Server Tools (`gamesvr`)

The `gamesvr` repo is a collection of tools to help build, test, maintain, backup, and publish Dockerized game servers.

* Must use the appropriate `/repos/<organization>` folder to store all repositories it manages.

## Game Server Repos (`gamesvr-**`)

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

### Game Server 'Levels'

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

### Build Scripts

If a game server is not built in the cloud (e.g. GitHub Actions), it must include a build script that can be run
locally to build, test, and push the docker image to the cloud. Game server repos that are built in the cloud may
optionally include a build script for local use, following the same conventions.

* Must be executable shell scripts located in the root of the repo.
* Must work regardless of the current working directory, and should be able to be run from any location on the
  system.
* Must call the related test script(s) as part of the build process before push/publish steps.
* Should create output in markdown format, making it easy to share their output with others.
* Should pass shellcheck validation, and should be linted with `shellcheck` before being committed to the repo.

### Test Scripts

* Every game server repo must include a test script.
* Test scripts are intentionally kept separate and composable so they can be run independently and reused by build scripts.

### Dockerfiles

* Must be located in the root of the repo.
* Must use ".Dockerfile" as the file extension.
* Most projects will only have one Dockerfile, but some projects may have multiple Dockerfiles for different purposes.
  * For a project with one Dockerfile, the default name should be `linux.Dockerfile`, as the default build target is a
  Linux-based image.
* Final image must use a non-root user to run the game server, that user must be created in the Dockerfile, and it
  must be set to use that user via the `USER` instruction in the Dockerfile.
* Multistage builds should be used to reduce the size of the final image, and to ensure that only necessary files are
  included in the final image.
* The final image should be as small as possible, and should not include any unnecessary files or dependencies.
* When possible, the final image should use UTF-8 as the default locale and should include any necessary packages to
  support UTF-8.
* Dockerfiles may specify an alternative escape character (e.g. `# escape=`) for any builds targetting the Microsoft
  Windows operating system. All other Dockerfile should stick to the default.

#### Build Arguments

* No unused ARGs are allowed.
* Build arguments may be placed:
  * Before any `FROM` instructions, for build arguments that are used in the `FROM`
    instruction(s).
  * After the `FROM` instruction, for build arguments that are used in the build process

#### Formatting

* In multi-stage builds, all but the first FROM instruction must:
  * Be proceeded by a comment separator of `#---------------------------------` with two blank lines before the comment.
* There must be at least one blank line between instructions.
* 4 spaces must be used for indentations.
* There must always be at least one space character ahead of any trailing line continuation character (`\`).

#### Labels

* All labels should be applied via a single `LABEL` instruction in the Dockerfile, with each value on a separated line
  using the line continuation character (`\`). Each subsequent line should be indented with 4 spaces, and the last line
  should not have a line continuation character.
* Dockerfiles must include the following labels for the final image:
  * `architecture` - The architecture of the image (by default `amd64`).
  * `com.lacledeslan.build-node` - The name of the host system that built the image.
    * ARG `BUILD_NODE` should be used to pass this value with a default value of `unspecified`.
  * `maintainer` - The maintainer of the image (by default `Laclede's LAN <contact@lacledeslan.com>`).
  * `org.opencontainers.image.description` - A description of the image (e.g. `<gamename> Dedicated Server`).
  * `org.opencontainers.image.revision` - The revision of the image (e.g. `git rev-parse HEAD`).
    * ARG `GIT_REVISION` should be used to pass the git revision to the Dockerfile (default `unspecified`):
      * it should be set in the build script to the output of `git rev-parse HEAD`.
      * if the git working tree is dirty, append the string `-dirty` to that SHA (for example: `<sha>-dirty`).
  * `org.opencontainers.image.source` - The source of the image (e.g. `https://github.com/LacledesLAN/gamesvr-hl2dm`).
  * `org.opencontainers.image.vendor` - The vendor of the image (e.g. `Laclede's LAN`).
