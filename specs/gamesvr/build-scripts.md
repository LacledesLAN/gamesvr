# Build Script Specs for Active `gamesvr` projects

Build scripts for active game server projects must provide a consistent interface for building, testing, and publishing
Docker images. The root `./build.sh` in the `gamesvr` repository is the sole orchestration script and is referred to in
this document as the orchestrator. It selects projects and coordinates repository build scripts without combining their
project lifecycles. Every other build script covered by this specification is a repository build script dedicated to
the images defined by its own repository.

## General Requirements

* Repository build scripts must follow the naming and location requirements under
  [Game Server Levels](readme.md#game-server-levels).
* Scripts must be executable, use Bash, and enable `errexit`, `nounset`, and `pipefail` behavior.
* Scripts must resolve paths relative to the script's location and must not depend on the caller's current working
  directory.
* Scripts must pass `shellcheck` validation before being committed.
* Scripts must validate required commands and access to the Docker daemon before starting a build.
* Scripts must reject unknown options, print the unknown option to standard error, and exit nonzero.
* Options must be order-independent and may be combined unless a combination is explicitly prohibited below.
* Scripts must exit zero only when every requested operation succeeds. A failed preflight, pull, build, test, push, or
  required cleanup operation must produce a nonzero exit status.

### Repository Lifecycle

* A repository build script must build, tag, test, push, and delete only images defined by its hosting repository. It may
  consume a parent or other dependency image, but it must not manage that dependency image's lifecycle.
* A repository build script must not select other projects, invoke another repository's build script, or coordinate
  builds across repositories. Cross-repository selection, dependency ordering, and lifecycle coordination belong only
  to the orchestrator.
* Unless an option explicitly changes its behavior, a repository build script must run its lifecycle in this order:
  preflight checks, pull, build and local tag creation, test, push, and cleanup.
* During the push step, the script must push each configured publishing-qualified tag only after the corresponding
  unqualified local tag satisfies the publishing preconditions below.
* A repository build script must complete its project lifecycle before returning control to its caller.

### Root Orchestration Lifecycle

* The orchestrator must run its lifecycle in this order: invocation-level preflight checks, build-target
  selection, orchestration-owned pulls, dependency-ordered repository build-script invocations, orchestration-owned
  cleanup, and final reporting.
* The orchestrator must invoke each selected repository build script as a complete project lifecycle. It must not
  combine the build, test, or push steps of multiple repository build scripts into shared phases.
* The failure of one project must affect scheduling only as defined under
  [Failure Handling](#failure-handling) and [`--fast-fail`](#--fast-fail).

## Image Names and Publishing

### Publishing Preconditions

* Unless `--skip-tests` is specified, the repository build script must execute that repository's required test script
  once for every built, unqualified local image tag configured for the invocation, passing that exact tag as required
  by the [Test Script Specs](test-scripts.md), regardless of whether `--skip-push` is specified.
* Unless `--skip-tests` is specified, the test script must complete successfully before the corresponding
  publishing-qualified tag is pushed. A missing or non-executable test script, or a nonzero test result, must fail the
  build and prevent that image from being pushed.
* When `--skip-tests` is specified without `--skip-push`, the script may publish untested images only after printing the
  warning required under [`--skip-tests`](#--skip-tests).

### Local and Publishing Tags

* Every locally built image must receive both an unqualified local tag and its configured registry- or
  organization-qualified publishing tag. For example, a build of `gamesvr-blackmesa` must create both
  `gamesvr-blackmesa` and `lacledeslan/gamesvr-blackmesa` locally.
* Any configured tag suffix, such as `:latest` or a version tag, must be applied to both forms of the image name.
* The unqualified and publishing-qualified tags for a configured suffix must refer to the same image. The script may
  provide both tags to the Docker build or add the publishing-qualified tag to the already-built image, but it must not
  rebuild the image solely to create the publishing-qualified tag.
* Tests must use the unqualified local image tags. Dependent builds must use the matching unqualified local parent tag
  when it is available to the selected Docker builder; `--no-base` builds may use the configured Docker Hub parent as
  a fallback as defined under [`--no-base`, `--skip-base`](#--no-base---skip-base).
* Pushes must use the publishing-qualified tags. Creating a publishing-qualified tag locally does not satisfy or bypass
  the publishing preconditions.
* All locally created tags must remain after successful or failed testing and publishing unless
  `--delete-built-image` is specified.

## Common Options

The root `./build.sh` orchestration script and every repository build script it may invoke, such as
`build-gamesvr-blackmesa.sh`, must accept every option in this section. The root orchestration script must pass every
received common option through unchanged to each invoked repository build script, including an option that does not
apply to that project. The only exception is `--delete-built-image`: when coordinating multiple builds, the orchestrator
must withhold it from repository build scripts and perform the required image cleanup itself in dependency-safe order.

### Inapplicable Options

A repository build script must not reject a common option merely because the project does not use the related feature
or has no applicable operation. In that case, the script must print a status message that names the received option,
states that it has no effect for that project or invocation, and continues normally. Option-specific behavior required
below, such as performing a full build when `--delta` is unsupported, still applies.

### `-d`, `--delta`

* `-d` and `--delta` must be equivalent.
* For projects that support delta updates, this option must build only the update layer or otherwise avoid rebuilding
  unchanged game-server content.
* For projects that cannot safely perform a delta update, the normal no-effect behavior is a full build.

### `--delete-built-image`

* Deletes gameserver Docker images, after being processed. The intent is to save hard drive space on the building
  machine, while still keeping all build functionality intact.
* A repository build script running independently must remove every unqualified and publishing-qualified local image
  tag it produced only after its requested tests and pushes finish.
* Cleanup of all tags created by the invocation must also be attempted when the script exits because a build, test, or
  push failed.
* Failure to remove an already absent image must not hide the original build, test, or push result.
* Combining this option with `--skip-push` is permitted as a build-validation workflow. Before building, the complete
  invocation must print a prominent warning that all requested builds and tests will run but no built image artifact
  will remain after successful cleanup.
* The orchestrator must retain each built image until every requested dependent build has been processed. A
  dependent build is processed when it succeeds, fails, or is explicitly recorded as skipped.
* At the end of each build step, the orchestrator may remove images for which no requested dependent build remains
  unprocessed. It must remove all local tags for child images before all local tags for their parent images and remove
  all remaining image tags produced by the invocation before the invocation finishes.
* For example, when `gamesvr-blackmesa` and `gamesvr-blackmesa-freeplay` are requested together, the orchestrator must
  not remove `gamesvr-blackmesa` until the `gamesvr-blackmesa-freeplay` build has succeeded, failed, or been recorded as
  skipped.

### `--enable-steamcmd-cache`

* The script must enable the project's local SteamCMD download cache and pass the corresponding configuration into the
  Docker build.
* The cache must be disabled by default.
* Enabling this cache must not change the final image contents except for the game-server files obtained through
  SteamCMD.

### `--no-docker-cache`

* The script must pass `--no-cache` to every Docker build performed by that invocation.
* This option controls Docker layer-cache matching only; it must not imply `--skip-pull` or disable the SteamCMD cache.

### `--progress-plain`

* The purpose of this option is to expose complete, noninteractive build progress and command output for easier
  troubleshooting.
* The script must pass `--progress=plain` to every Docker build performed by that invocation, including builds executed
  through `docker buildx build`.
* The script must not filter, truncate, collapse, or otherwise suppress Docker build output when this option is enabled.
* This option must not change cache, pull, test, push, tagging, or cleanup behavior.

### `--skip-pull`

* The script must omit explicit image pulls and must not pass `--pull` to Docker builds.
* Docker may fetch a base image or other image-based build input when it is not already available to the selected
  Docker builder.
* Images already available to the selected Docker builder must not be proactively refreshed or pulled solely because a
  newer remote image may exist.
* This option must not imply `--no-docker-cache`.

### `--skip-tests`

* The script must skip all project test scripts and image self-checks.
* This option must not imply `--skip-push` or otherwise prevent publishing.
* When `--skip-push` is not also specified, the script must print a prominent warning before starting the build that
  the requested images will be pushed without testing, then continue the normal lifecycle with the test step skipped.

### `--skip-push`

* The script must not authenticate to a registry or push any image. It must still create every configured unqualified
  and publishing-qualified local tag during the build step.
* This option affects only publishing operations. Unless `--skip-tests` is also present, the script must still run all
  tests against every built, unqualified local image tag configured for the invocation.
* All locally created image tags must remain available unless `--delete-built-image` is also present.

## Orchestration Options

The options in this section apply only to the root `./build.sh` orchestrator in the `gamesvr` repository. Repository
build scripts must not accept these options, and the orchestrator must not pass them through to repository build
scripts.

### Build Target Selection

* A build target is an orchestration-only identifier that maps a command-line selector to one or more game-server
  projects. Repository build scripts must not accept build-target selectors, and the orchestrator must not pass
  those selectors to repository build scripts.
* Each target's project membership and dependency relationships must be explicitly configured by the orchestrator and
  must not be inferred solely from repository-name prefixes or hyphens.
* Selecting a build target must select every project configured for that target, subject to dependency failures and
  orchestration options. Projects belonging exclusively to an unselected target must not be built, tested, pushed, or
  removed.
* Multiple build-target selectors may be combined and must be order-independent. Each selected project must be
  processed no more than once, even if it belongs to multiple selected targets.
* When no build-target selector is supplied, the orchestrator must select every configured build target.
* For example, `--blackmesa` selects `gamesvr-blackmesa` and `gamesvr-blackmesa-freeplay`, while `--tf2` selects
  `gamesvr-tf2` and `gamesvr-tf2-freeplay`.
* For each selected project that remains in the execution set after applying orchestration options, the orchestrator
  must invoke that project's repository build script exactly once. A selected project excluded from the execution set
  by an orchestration option must not be invoked.
* A repository build script must finish its complete project lifecycle before the orchestrator invokes the next
  project.
* First-level projects in the execution set must be processed before their selected second-level dependents.

### Failure Handling

* Unless `--fast-fail` is enabled, the orchestrator must continue running every requested build that can still succeed
  after a failure. One failed build must not prevent independent first-level projects or their viable second-level
  projects from being attempted.
* A first-level project is a base game-server project, such as `gamesvr-name`. A second-level project is a project built
  from that first-level image, such as `gamesvr-name-sub`, as defined under
  [Game Server Levels](readme.md#game-server-levels).
* If a first-level build fails, the orchestrator must not invoke or otherwise attempt to build any second-level project
  that depends on it. Each affected second-level project must be reported as skipped in the final summary.
* Dependency skipping is mandatory regardless of whether `--fast-fail` is enabled. The final summary must report each
  affected project as skipped and identify the failed dependency as the reason.
* Unless `--fast-fail` is enabled, a failure in one build target must not prevent viable projects in another selected
  build target from being processed.

### `--fast-fail`

* The orchestrator must stop scheduling additional builds immediately after the first failed build.
* The orchestrator must preserve the failing build's result in its final output and exit nonzero.
* Every selected project not attempted because of `--fast-fail` must be reported as skipped in the final summary, with
  `--fast-fail` identified as the reason.
* Without this option, the orchestrator must follow the continuation and dependency-skipping requirements above so the
  final report includes all attempted failures.

### `--no-base`, `--skip-base`

* `--no-base` and `--skip-base` must be equivalent aliases.
* The orchestrator must remove selected first-level projects from the execution set without removing them from the
  selected-project set used for dependency resolution and final reporting. The final summary must report each removed
  first-level project as skipped and identify the received option as the reason. The orchestrator must still build
  selected second-level images that depend on them.
* Before building a requested second-level image, the orchestrator must determine whether the matching unqualified
  first-level image and tag are available to the selected Docker builder.
* If the matching parent is available locally, the second-level build must use that image without replacing it with a
  newer remote image solely because `--no-base` was specified.
* If the matching parent is not available locally, the second-level build must use the corresponding image and tag
  from the configured Docker Hub organization. The repository build script must configure the parent image reference
  so the Dockerfile can use either the local or Docker Hub source.
* Unless `--skip-pull` is also present, the orchestrator may explicitly pull a missing Docker Hub parent before the
  second-level build. With `--skip-pull`, it must not explicitly pull the parent, but the selected Docker builder may
  fetch that parent while resolving a missing build input.
* Failure to resolve the matching parent image must fail the affected second-level build normally.

## Output and Reporting

The complete output of an orchestrator invocation must be a well-formed Markdown document that can be copied directly
into a Markdown file, GitHub issue, pull request, or discussion and rendered without modification. Repository build
scripts must emit well-formed Markdown fragments that the orchestrator can include in that document without
modification.

### Document Structure

* The first nonblank output line from the orchestrator must be a single level-one heading (`#`) that identifies
  the build invocation. The complete orchestration output must contain exactly one level-one heading.
* Only the root `./build.sh` orchestrator in the `gamesvr` repository may emit a level-one heading.
* A repository build script must not emit a level-one heading. Its first nonblank output line must be a level-two
  heading (`##`) that identifies the project lifecycle, and its subsequent sections must use level-three or deeper
  headings in a logical hierarchy without skipping heading levels.
* The orchestrator must include each repository build script's Markdown fragment without placing the fragment inside a
  fenced code block.
* Headings, lists, paragraphs, links, inline code, and fenced code blocks must follow GitHub Flavored Markdown syntax.
* Blank lines must separate headings, paragraphs, lists, and fenced code blocks where required for unambiguous rendering.
* Scripts must not emit ANSI color codes, cursor controls, progress animations, or other terminal escape sequences.

### Command Output

* Except for Markdown fragments emitted by repository build scripts, all output produced by external commands, child
  scripts, tests, Docker, or other subprocesses must be enclosed in a fenced code block.
* The opening and closing fences must each appear on their own line and must use matching backtick delimiters of at
  least three backticks. A fence longer than any backtick sequence in the captured output must be used when necessary.
* A suitable info string, such as `console` or `text`, should follow the opening fence when it improves rendering.
* Both standard output and standard error from a command must remain inside that command's fenced code block.
* Every opened code block must be closed, including when the command fails or the script receives a termination signal.
* Script-authored status text, headings, summaries, warnings, and errors must not be placed inside a code block unless
  they are part of captured command output.

### Status and Summary

* Scripts must report when an option skips or changes a lifecycle step.
* The orchestrator must provide a final summary containing every selected project exactly once. The summary must
  identify each project's build target and report it as built successfully, failed, or skipped.
* Every skipped project must include a reason, such as exclusion by `--no-base` or `--skip-base`, a failed dependency,
  or scheduling stopped by `--fast-fail`.
* Status and summary output should use Markdown lists or tables when reporting multiple items.
* Error and warning messages must identify the affected operation or option, use valid Markdown, and be written to
  standard error.
* Writing warnings or errors to standard error must not break the Markdown structure when standard output and standard
  error are combined into one log.
