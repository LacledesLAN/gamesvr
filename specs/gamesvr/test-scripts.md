# Test Script Specs for Active `gamesvr` Projects

Test scripts validate locally built game-server Docker images independently of the build scripts that produced them.

## General Requirements

* Test scripts must be executable Bash scripts located in the repository root.
* Every Bash function must comply with the shared
  [Function Documentation](../shell-scripts.md#function-documentation) requirements.
* A first-level project's test script must be named `test-gamesvr-<game_name>.sh`.
* A second-level project's test script must be named `test-gamesvr-<game_name>-<scope>.sh`.
* Scripts must resolve paths relative to the script's location and must not depend on the caller's current working
  directory.
* Scripts must exit zero only when every test succeeds and exit nonzero when any test fails.
* Test results should be stored in a `tests` directory in the repository root, with all generated log files ignored via
  `.gitignore`.

## Image Tag Argument

* A test script must accept exactly one positional argument containing the unqualified local Docker image tag to test.
  For example: `./test-gamesvr-blackmesa.sh gamesvr-blackmesa:latest`.
* The argument must include the repository image name and may include a tag suffix, but must not include a registry
  hostname or organization namespace.
* The script must test the exact image tag supplied by the caller and must not substitute a default tag.
* A missing, empty, registry-qualified, or additional argument must produce an error on standard error and a nonzero
  exit status before tests begin.

Test scripts are intentionally separate and composable so they can be run independently and reused by build scripts.
