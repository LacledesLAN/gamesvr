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
* At the beginning of a repository build script, before producing any output or invoking any command that may produce
  output, the script must save its original standard output and redirect standard output to standard error. This makes
  all lifecycle output, diagnostics, and subprocess output visible on standard error by default.
* Before exiting, a repository build script must restore its original standard output and write only the image-tag list
  defined under [Repository Build-Script Output](#repository-build-script-output) to standard output.

### Repository Lifecycle

* A repository build script must build, tag, test, and push only images defined by its hosting repository. It may
  consume a parent or other dependency image, but it must not manage that dependency image's lifecycle or delete any
  built image.
* A repository build script must not select other projects, invoke another repository's build script, or coordinate
  builds across repositories. Cross-repository selection, dependency ordering, and lifecycle coordination belong only
  to the orchestrator.
* Unless an option explicitly changes its behavior, a repository build script must run its lifecycle in this order:
  preflight checks, pull, build and local tag creation, test, and push.
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
  [Failure Handling](#failure-handling) and [`--fail-fast`](#--fail-fast).

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
* All locally created tags must remain after successful or failed testing and publishing. Only the orchestrator may
  remove built image tags when its `--delete-built-image` option is specified.

## Common Options

The root `./build.sh` orchestration script and every repository build script it may invoke, such as
`build-gamesvr-blackmesa.sh`, must accept every option in this section. The root orchestration script must pass every
received common option through unchanged to each invoked repository build script, including an option that does not
apply to that project.

### Inapplicable Options

A repository build script must not reject a common option merely because the project does not use the related feature
or has no applicable operation. In that case, the script must print a status message that names the received option,
states that it has no effect for that project or invocation, and continues normally. Option-specific behavior required
below, such as performing a full build when `--delta` is unsupported, still applies.

### `--delta`

* For projects that support delta updates, this option must build only the update layer or otherwise avoid rebuilding
  unchanged game-server content.
* For projects that cannot safely perform a delta update, the normal no-effect behavior is a full build.

### `--enable-steamcmd-cache`

* The script must enable the project's local SteamCMD download cache and pass the corresponding configuration into the
  Docker build.
* The cache must be disabled by default.
* Enabling this cache must not change the final image contents except for the game-server files obtained through
  SteamCMD.

### `--disable-docker-cache`

* The script must pass `--no-cache` to every Docker build performed by that invocation.
* This option controls Docker layer-cache matching only; it must not imply `--skip-pull` or disable the SteamCMD cache.

### `--progress-plain`

* The purpose of this option is to expose complete, noninteractive build progress and command output for easier
  troubleshooting.
* The script must pass `--progress=plain` to every Docker build performed by that invocation, including builds executed
  through `docker buildx build`.
* The script must pass `--no-progress` to git commands (if `--quiet` is already being passed this is not required).
* The script must not filter, truncate, collapse, or otherwise suppress Docker build output when this option is enabled.
* This option must not change cache, pull, test, push, tagging, or cleanup behavior.

### `--skip-pull`

* The script must omit explicit image pulls and must not pass `--pull` to Docker builds.
* Docker may fetch a base image or other image-based build input when it is not already available to the selected
  Docker builder.
* Images already available to the selected Docker builder must not be proactively refreshed or pulled solely because a
  newer remote image may exist.
* This option must not imply `--disable-docker-cache`.

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
* All locally created image tags must remain available after a repository build script exits.

## Orchestration Options

The options in this section apply only to the root `./build.sh` orchestrator in the `gamesvr` repository. Repository
build scripts must not accept these options, and the orchestrator must not pass them through to repository build
scripts.

### `--delete-built-image`

* Deletes gameserver Docker images after they have been processed. The intent is to save hard drive space on the
  building machine while retaining all build, test, and publishing behavior.
* This option is accepted only by the orchestrator. Repository build scripts must reject it as an unknown option, and
  the orchestrator must not pass it to repository build scripts.
* The orchestrator must capture and retain the complete newline-delimited image-tag list written to standard output by
  every repository build script it invokes, regardless of whether `--delete-built-image` was specified. It must
  preserve the repository build script's exit status separately from the captured output.
* The captured list is the authoritative set of image tags produced by that repository build-script invocation. The
  orchestrator must not infer cleanup tags from project names, configured suffixes, or repository relationships.
* When `--delete-built-image` is specified, the orchestrator must delete every tag in each captured list. When the
  option is not specified, it must not delete any captured tag.
* Cleanup of all reported tags must also be attempted when a repository build script exits because a build, test, or
  push failed. Failure to remove an already absent image must not hide the original build, test, or push result.
* Combining this option with `--skip-push` is permitted as a build-validation workflow. Before building, the complete
  invocation must print a prominent warning that all requested builds and tests will run but no built image artifact
  will remain after successful cleanup.
* The orchestrator must retain each built image until every requested direct or transitive dependent has been
  processed. A dependent is processed when its repository build script succeeds or fails, or when the orchestrator
  explicitly records it as skipped.
* Cleanup must occur in reverse dependency order. Before deleting any tag returned by a parent repository build script,
  the orchestrator must finish processing every requested child and transitive descendant and must finish deleting all
  tags returned by those descendants. Tags returned for a project may be deleted only when no requested dependent
  remains unprocessed or has captured tags awaiting deletion.
* The orchestrator must remove all remaining captured tags before the invocation finishes. A tag must not be deleted
  merely because a repository build script has returned if another requested build may still use that image.
* For example, when `gamesvr-hl2dm` and `gamesvr-hl2dm-freeplay` are requested together, the orchestrator must build
  `gamesvr-hl2dm-freeplay` before deleting any tag returned by `gamesvr-hl2dm`. It must delete all tags returned by
  `gamesvr-hl2dm-freeplay` before deleting the tags returned by `gamesvr-hl2dm`.

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

* Unless `--fail-fast` is enabled, the orchestrator must continue running every requested build that can still succeed
  after a failure. One failed build must not prevent independent first-level projects or their viable second-level
  projects from being attempted.
* A first-level project is a base game-server project, such as `gamesvr-name`. A second-level project is a project built
  from that first-level image, such as `gamesvr-name-sub`, as defined under
  [Game Server Levels](readme.md#game-server-levels).
* If a first-level build fails, the orchestrator must not invoke or otherwise attempt to build any second-level project
  that depends on it. Each affected second-level project must be reported as skipped in the final summary.
* Dependency skipping is mandatory regardless of whether `--fail-fast` is enabled. The final summary must report each
  affected project as skipped and identify the failed dependency as the reason.
* Unless `--fail-fast` is enabled, a failure in one build target must not prevent viable projects in another selected
  build target from being processed.

### `--fail-fast`

* This option is accepted only by the orchestrator. Repository build scripts must reject it as an unknown option, and
  the orchestrator must not pass it to repository build scripts.
* The orchestrator must stop scheduling additional builds immediately after the first failed build.
* The orchestrator must preserve the failing build's result in its final output and exit nonzero.
* Every selected project not attempted because of `--fail-fast` must be reported as skipped in the final summary, with
  `--fail-fast` identified as the reason.
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
scripts must emit their human-readable, well-formed Markdown fragments on standard error so that standard output is
reserved for machine-readable image tags. The orchestrator may combine those fragments into its Markdown document.

### Repository Build-Script Output

* A repository build script must write to standard output every local Docker image tag successfully created by the
  invocation, including every unqualified tag and every publishing-qualified tag.
* Each tag must be written exactly once on its own line, with no bullets, headings, quoting, blank lines, or other
  formatting. A script that creates no image tags must produce no standard output.
* The complete tag list must be emitted immediately before the script exits, after restoring the original standard
  output. This requirement applies to both successful and failed invocations; a failed invocation must report any tags
  it successfully created before the failure.
* Image tags are the only content a repository build script may write to standard output. All script-authored status,
  warning, error, and Markdown output, and all output from commands, tests, Docker, and other subprocesses, must be
  written to standard error.
* The newline-delimited format must allow a caller to capture the complete tag list with command substitution or an
  equivalent standard-output capture mechanism while lifecycle output continues to be displayed on standard error.

### Document Structure

* The first nonblank output line from the orchestrator must be a single level-one heading (`#`) that identifies
  the build invocation. The complete orchestration output must contain exactly one level-one heading.
* Only the root `./build.sh` orchestrator in the `gamesvr` repository may emit a level-one heading.
* A repository build script must not emit a level-one heading in its human-readable standard-error output. Its first
  nonblank human-readable line must be a level-two heading (`##`) that identifies the project lifecycle, and its
  subsequent sections must use level-three or deeper headings in a logical hierarchy without skipping heading levels.
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
* Both output streams from a command must remain inside that command's fenced code block. In a repository build script,
  the script-level redirection must send the complete fenced block to standard error; command output must never bypass
  that redirection and reach the repository build script's standard output.
* Every opened code block must be closed, including when the command fails or the script receives a termination signal.
* Script-authored status text, headings, summaries, warnings, and errors must not be placed inside a code block unless
  they are part of captured command output.

### Status and Summary

* Scripts must report when an option skips or changes a lifecycle step.
* The orchestrator must provide a final summary containing every selected project exactly once. The summary must
  identify each project's build target and report it as built successfully, failed, or skipped.
* Every skipped project must include a reason, such as exclusion by `--no-base` or `--skip-base`, a failed dependency,
  or scheduling stopped by `--fail-fast`.
* Status and summary output should use Markdown lists or tables when reporting multiple items.
* Error and warning messages must identify the affected operation or option, use valid Markdown, and be written to
  standard error.
* Writing warnings or errors to standard error must not break the Markdown structure when output streams are combined
  into one human-readable log. Machine-readable repository image-tag output must remain separately capturable.
