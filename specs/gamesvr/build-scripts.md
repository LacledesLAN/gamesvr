# Repository Build Script Specs for Active `gamesvr` Projects

Repository build scripts for active game-server projects must provide a consistent interface for building, testing,
and publishing Docker images defined by their hosting repositories. The root `./build.sh` orchestration script is
covered by the [Build Orchestrator Specs](../build-orchestrator.md).

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
  to the orchestrator defined by the [Build Orchestrator Specs](../build-orchestrator.md).
* Unless an option explicitly changes its behavior, a repository build script must run its lifecycle in this order:
  preflight checks, pull, build and local tag creation, test, and push.
* During the push step, the script must push each configured publishing-qualified tag only after the corresponding
  unqualified local tag satisfies the publishing preconditions below.
* A repository build script must complete its project lifecycle before returning control to its caller.

## Image Names and Publishing

### Publishing Preconditions

* Unless `--skip-tests` is specified, the repository build script must execute that repository's required test script
  exactly once for each distinct image configured to be pushed directly to a remote registry, passing a corresponding
  unqualified local tag for that exact image as required by the [Test Script Specs](test-scripts.md). An image with
  multiple publishing-qualified tags still requires only one test. Intermediate images and other images without a
  publishing-qualified tag are not required to be tested. These requirements apply regardless of whether
  `--skip-push` is specified; that option suppresses the push operation without changing which publishable images are
  tested.
* Unless `--skip-tests` is specified, the test script must complete successfully before any publishing-qualified tag
  for the tested image is pushed. A missing or non-executable test script, or a nonzero test result, must fail the
  build and prevent that image from being pushed.
* When `--skip-tests` is specified without `--skip-push`, the script may publish untested images only after printing the
  warning required under [`--skip-tests`](../build-orchestrator.md#--skip-tests).

### Local and Publishing Tags

* Every image configured to be pushed directly to a remote registry must receive both an unqualified local tag and its
  configured registry- or organization-qualified publishing tag. For example, a publishable build of
  `gamesvr-blackmesa` must create both `gamesvr-blackmesa` and `lacledeslan/gamesvr-blackmesa` locally. Intermediate
  images that are not configured for direct publication do not require either tag solely for compliance with this
  specification.
* Any configured tag suffix, such as `:latest` or a version tag, must be applied to both forms of the image name.
* The unqualified and publishing-qualified tags for a configured suffix must refer to the same image. The script may
  provide both tags to the Docker build or add the publishing-qualified tag to the already-built image, but it must not
  rebuild the image solely to create the publishing-qualified tag.
* Tests must use an unqualified local tag for the exact publishable image under test. Dependent builds must use the
  matching unqualified local parent tag when it is available to the selected Docker builder; `--no-base` builds may
  use the configured Docker Hub parent as a fallback as defined under
  [`--no-base`, `--skip-base`](../build-orchestrator.md#--no-base---skip-base).
* Pushes must use the publishing-qualified tags. Creating a publishing-qualified tag locally does not satisfy or bypass
  the publishing preconditions.
* All locally created tags must remain after successful or failed testing and publishing. Only the orchestrator may
  remove built image tags when its `--delete-built-image` option is specified.

## Common Options

Repository build scripts must accept and implement every option under
[Common Build Options](../build-orchestrator.md#common-build-options). Those option definitions form the shared
command-line interface between the orchestrator and repository build scripts.

Repository build scripts must reject orchestration-only options and build-target selectors as unknown options. The
canonical list of orchestration-only options is defined under
[Orchestration Options](../build-orchestrator.md#orchestration-options).

## Output and Reporting

Repository build scripts must emit human-readable, well-formed Markdown fragments on standard error so that standard
output is reserved for machine-readable image tags. The orchestrator combines these fragments as defined by the
[Build Orchestrator Specs](../build-orchestrator.md#output-and-reporting).

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

* A repository build script must not emit a level-one heading in its human-readable standard-error output. Its first
  nonblank human-readable line must be a level-two heading (`##`) that identifies the project lifecycle, and its
  subsequent sections must use level-three or deeper headings in a logical hierarchy without skipping heading levels.
* Headings, lists, paragraphs, links, inline code, and fenced code blocks must follow GitHub Flavored Markdown syntax.
* Blank lines must separate headings, paragraphs, lists, and fenced code blocks where required for unambiguous rendering.
* Scripts must not emit ANSI color codes, cursor controls, progress animations, or other terminal escape sequences.

### Command Output

* All output produced by external commands, child scripts, tests, Docker, or other subprocesses must be enclosed in a
  fenced code block.
* The opening and closing fences must each appear on their own line and must use matching backtick delimiters of at
  least three backticks. A fence longer than any backtick sequence in the captured output must be used when necessary.
* A suitable info string, such as `console` or `text`, should follow the opening fence when it improves rendering.
* Both output streams from a command must remain inside that command's fenced code block. The script-level redirection
  must send the complete fenced block to standard error; command output must never bypass that redirection and reach
  the repository build script's standard output.
* Every opened code block must be closed, including when the command fails or the script receives a termination signal.
* Script-authored status text, headings, summaries, warnings, and errors must not be placed inside a code block unless
  they are part of captured command output.

### Status and Summary

* Scripts must report when an option skips or changes a lifecycle step.
* Status and summary output should use Markdown lists or tables when reporting multiple items.
* Error and warning messages must identify the affected operation or option, use valid Markdown, and be written to
  standard error.
* Writing warnings or errors to standard error must not break the repository's Markdown fragment. Machine-readable
  repository image-tag output must remain separately capturable.
