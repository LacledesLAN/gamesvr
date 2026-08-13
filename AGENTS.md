# Instructions for Agents

This `gamesvr` repo is a collection of tools to help build, test, maintain, backup, and publish Dockerized game servers.

* Must use the appropriate `/repos/<organization>` folder to store all repositories it manages.

## Active `gamesvr` repos

Active game server repos are managed in the `repos/gameservers` folder and are expected to be maintained and updated as
needed. The canonical specifications for these repositories must live in `specs/gamesvr`, not in an individual game
server repository.

* [Specs for active `gamesvr` projects](specs/gamesvr/readme.md) must be followed by every active game server repository.
* [Dockerfile Specs for active `gamesvr` projects](specs/gamesvr/dockerfiles.md) must be followed by all Dockerfiles in
  active game server repositories.
* [Build Orchestrator Specs](specs/build-orchestrator.md) must be followed by the root `build.sh` orchestration script.

## Archived
