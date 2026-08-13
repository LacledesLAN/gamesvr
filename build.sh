#!/bin/bash
set -euo pipefail

printf '# gamesvr build invocation\n\n'

# Build Laclede's LAN game server docker images, that are too large to be built in Github actions.

####################################################################################################
## Environment
####################################################################################################

GAMESVR_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${GAMESVR_ROOT}/bin/funcs.sh"
require_command git
require_command docker
LL_GAMESVR_BLD_COMMAND="$0 $*"
LL_GAMESVR_BLD_START_TIME=$(date +%s)

####################################################################################################
## Options
####################################################################################################

build_options=()
orchestrator_build_targets=()
orchestrator_options=()

# Track the results of each build for reporting at the end of the script
builds_aborted=()
builds_completed=()
builds_failed=()
builds_skipped=()
build_order=()
declare -A build_image_tags=()
declare -A build_skip_reasons=()
image_cleanup_completed=false
image_cleanup_status=0
scheduling_stopped=false
command_fence_open=false

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        # Orchestrator options.
        --delete-built-image)        orchestrator_options+=('delete-built-image') ;;
        --fail-fast)                 orchestrator_options+=('fail-fast') ;;
        --no-base|--skip-base)       orchestrator_options+=('skip-base') ;;

        # Build targets; exclusive to orchestrator. Aliases map cleanly to their core folder names
        --7days|--7daystodie)        orchestrator_build_targets+=('7daystodie') ;;
        --blackmesa)                 orchestrator_build_targets+=('blackmesa') ;;
        --tf2)                       orchestrator_build_targets+=('tf2') ;;
        --tf2c|--tf2classified)      orchestrator_build_targets+=('tf2classified') ;;

        # Build options; passed down to child scripts for Docker build customization
        --delta)                     build_options+=('--delta') ;;
        --enable-steamcmd-cache)     build_options+=('--enable-steamcmd-cache') ;;
        --disable-docker-cache)      build_options+=('--disable-docker-cache') ;;
        --progress-plain)            build_options+=('--progress-plain') ;;
        --skip-pull)                 build_options+=('--skip-pull') ;;
        --skip-push)                 build_options+=('--skip-push') ;;
        --skip-tests)                build_options+=('--skip-tests') ;;

        # Catch and exit if any unknown options are provided
        *)
            printf "Error: unknown option '%s'. Exiting.\n" "$1" >&2
            exit 12
            ;;
    esac
    shift
done

####################################################################################################
## Helper Functions
####################################################################################################

run_fenced() {
    local command_status=0
    local escape_character=$'\033'

    printf '````````console\n'
    command_fence_open=true
    if "$@" 2>&1 | tr '\r' '\n' | sed -E "s/${escape_character}\\[[0-9;?]*[[:alpha:]]//g"; then
        command_status=${PIPESTATUS[0]}
    else
        command_status=${PIPESTATUS[0]}
    fi
    command_fence_open=false
    printf '````````\n\n'
    return "$command_status"
}

# USAGE: has_orchestrator_option "option_name"
# PURPOSE: Checks if a specific orchestration flag exists in the global 'orchestrator_options' array.
# ARGS: $1 = The string option to search for (e.g., 'fail-fast')
# RETURNS: 0 if option is found, 1 otherwise
function has_orchestrator_option {
    local element
    for element in "${orchestrator_options[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

# USAGE: has_build_option "option_name"
# PURPOSE: Checks if a specific Docker build flag exists in the global 'build_options' array.
# ARGS: $1 = The string option to search for (e.g., '--skip-pull')
# RETURNS: 0 if option is found, 1 otherwise
function has_build_option {
    local element
    for element in "${build_options[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

# USAGE: builds_failed_includes "image_name"
# PURPOSE: Determines if a given image build has failed by checking the global 'builds_failed' array.
# ARGS: $1 = Name of the base image to check
# RETURNS: 0 if the image is in the failure list, 1 otherwise
function builds_failed_includes {
    local element
    for element in "${builds_failed[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

# USAGE: orchestrator_build_targets_include "game_shortname"
# PURPOSE: Determines if a specific game target should be built. If no specific targets
#          were requested via command line arguments, it assumes all targets are included.
# ARGS: $1 = Internal shortname of the game target (e.g., 'tf2')
# RETURNS: 0 if target should be built (or array is empty), 1 if target should be skipped
function orchestrator_build_targets_include {
    [[ ${#orchestrator_build_targets[@]} -eq 0 ]] && return 0
    local element
    for element in "${orchestrator_build_targets[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

# USAGE: fail_error "context_message"
# PURPOSE: Prints a standardized failure message to stderr and aborts script execution.
# ARGS: $1 = Descriptive text indicating what action or command failed
# RETURNS: None (exits script with code 1)
function fail_error {
    echo >&2 "'$1' failed. Exiting."
    exit 1
}

# USAGE: join_by "delimiter" "${array[@]}"
# PURPOSE: Safely concatenates array elements together into a single string separated by a delimiter.
# ARGS: $1 = Delimiter character/string (e.g., ', ')
#       $2... = Elements of the array to be joined
# RETURNS: Outputs the combined string to stdout
function join_by {
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

# shellcheck disable=SC2329 # Invoked by the EXIT-trap handler.
# USAGE: cleanup_built_images
# PURPOSE: Removes captured image tags in reverse repository build order when requested.
# ARGS: None
# RETURNS: 0 if cleanup is disabled or every existing tag is removed, 1 if a required removal fails
function cleanup_built_images {
    if [[ "$image_cleanup_completed" == true ]]; then
        return "$image_cleanup_status"
    fi

    if ! has_orchestrator_option 'delete-built-image'; then
        image_cleanup_completed=true
        return 0
    fi

    local index
    local inspect_output
    local project
    local tag

    printf '## Cleanup\n\n'

    for ((index=${#build_order[@]} - 1; index >= 0; index--)); do
        project="${build_order[$index]}"
        while IFS= read -r tag; do
            [[ -z "$tag" ]] && continue

            if ! inspect_output=$(docker image inspect "$tag" 2>&1); then
                if [[ "$inspect_output" == *'No such image'* ]]; then
                    continue
                fi

                printf "ERROR: Failed to inspect built image tag '%s' reported by '%s'.\n\n" "$tag" "$project" >&2
                run_fenced printf '%s\n' "$inspect_output"
                image_cleanup_status=1
                continue
            fi

            if ! run_fenced docker image rm -- "$tag"; then
                printf "ERROR: Failed to remove built image tag '%s' reported by '%s'.\n" "$tag" "$project" >&2
                image_cleanup_status=1
            fi
        done <<< "${build_image_tags[$project]:-}"
    done

    image_cleanup_completed=true
    return "$image_cleanup_status"
}

# shellcheck disable=SC2329 # Invoked by the EXIT trap.
# USAGE: on_exit
# PURPOSE: Performs orchestration-owned cleanup and preserves the authoritative invocation status.
# ARGS: None
# RETURNS: None (exits with the saved status, or 1 when cleanup alone fails)
function on_exit {
    local exit_status=$?

    trap - EXIT HUP INT TERM
    trap '' HUP INT TERM

    if [[ "$command_fence_open" == true ]]; then
        printf '````````\n\n'
        command_fence_open=false
    fi

    if ! cleanup_built_images && [[ "$exit_status" -eq 0 ]]; then
        exit_status=1
    fi

    exit "$exit_status"
}

# USAGE: report_build "target_name" "exit_code"
# PURPOSE: Records an individual build result and stops future scheduling after a fail-fast failure.
# ARGS: $1 = Name of the image target that just finished building
#       $2 = Numerical exit code returned by the target's build script
# RETURNS: None
function report_build {
    local target="$1"
    local exit_code="$2"

    if [ "$exit_code" -eq 0 ]; then
        builds_completed+=("$target")
    else
        builds_failed+=("$target")
        if has_orchestrator_option 'fail-fast'; then
            printf "Build '%s' failed (Exit: %s). Stopping additional scheduling because --fail-fast was specified.\n" "$target" "$exit_code" >&2
            scheduling_stopped=true
        fi
    fi
}

# shellcheck disable=SC2329 # Invoked by signal traps.
# USAGE: sigterm_handler "signal_number"
# PURPOSE: Acts as a clean-up interface triggered upon receiving termination signals (SIGINT, SIGTERM, etc.).
# ARGS: $1 = Signal number used to produce the conventional process status
# RETURNS: None (exits script with 128 plus the signal number)
sigterm_handler() {
    local signal_number="$1"
    exit "$((128 + signal_number))"
}

####################################################################################################
## Preflight Checks
####################################################################################################

if ! docker info &> /dev/null; then
    printf "ERROR: Docker is installed, but the current user cannot access the Docker daemon.\n" >&2
    exit 1
fi

trap on_exit EXIT
trap 'sigterm_handler 1' HUP
trap 'sigterm_handler 2' INT
trap 'sigterm_handler 15' TERM

if has_orchestrator_option 'skip-base'; then
    echo -e "Skipping base image builds.\n"
fi

if has_orchestrator_option 'delete-built-image' && has_build_option '--skip-push'; then
    printf 'WARNING: --delete-built-image and --skip-push were both specified. All requested builds and tests will run, but no built image artifact will remain after successful cleanup.\n' >&2
fi

####################################################################################################
## Build Engine
####################################################################################################

# Target layout printing
if [ ${#orchestrator_build_targets[@]} -eq 0 ]; then
    printf 'Build target: **all configured targets**.\n\n'
else
    printf "Build targets: \`%s\`.\n\n" "$(join_by ', ' "${orchestrator_build_targets[@]}")"
fi

if ! has_build_option '--skip-pull'; then
    printf '## Pull shared images\n\n'
    run_fenced docker pull lacledeslan/steamcmd
else
    echo -e "Skipping pull of lacledeslan/steamcmd.\n"
fi

# USAGE: execute_build_pipeline "shortname" "UI Header Title" [derivatives...]
# PURPOSE: Reusable orchestration engine that syncs specialized git repositories, builds
#          the core game server base image, and sequentially processes downstream configurations.
# ARGS: $1 = Internal game directory/file hook keyword (e.g., 'tf2')
#       $2 = Clean user-interface heading title (e.g., 'TF2')
#       $3... = Zero or more optional space-separated sub-mod/mode suffixes (e.g., 'freeplay')
# RETURNS: 0 if target is skipped or successfully processed
function execute_build_pipeline() {
    local game_id="$1"
    local ui_name="$2"
    shift 2
    local derivatives=("$@")

    ! orchestrator_build_targets_include "$game_id" && return 0

    local base_image="gamesvr-${game_id}"

    if has_orchestrator_option 'skip-base'; then
        builds_skipped+=("$base_image")
        build_skip_reasons["$base_image"]='base builds disabled by --skip-base or --no-base'
    fi

    if [[ "$scheduling_stopped" == true ]]; then
        if ! has_orchestrator_option 'skip-base'; then
            builds_aborted+=("$base_image")
            build_skip_reasons["$base_image"]='--fail-fast stopped scheduling'
        fi

        local skipped_deriv
        for skipped_deriv in "${derivatives[@]}"; do
            local skipped_image="${base_image}-${skipped_deriv}"
            builds_aborted+=("$skipped_image")
            build_skip_reasons["$skipped_image"]='--fail-fast stopped scheduling'
        done
        return 0
    fi

    printf '## %s\n\n' "$ui_name"
    printf '### Fetch repositories\n\n'

    run_fenced "${GAMESVR_ROOT}/bin/reindex-${game_id}.sh" || fail_error "Fetch $ui_name repos"

    # 1. Base Build
    if ! has_orchestrator_option 'skip-base'; then
        printf "### Build \`%s\`\n\n" "$base_image"

        # Note the '|| true' or explicit assignments bypass 'set -e' crashes, allowing report_build to catch it
        local status=0
        local image_tags=""
        image_tags="$(
            cd -- "${GAMESVR_ROOT}/repos/gameservers/${base_image}"
            "./build-${base_image}.sh" "${build_options[@]}"
        )" || status=$?
        build_image_tags["$base_image"]="$image_tags"
        build_order+=("$base_image")
        report_build "$base_image" "$status"
    fi

    # 2. Dynamic Derivative Builds
    local deriv
    for deriv in "${derivatives[@]}"; do
        local deriv_image="${base_image}-${deriv}"

        if builds_failed_includes "$base_image"; then
            printf "### Build \`%s\`\n\n" "$deriv_image"
            echo -e "Skipped (Base image failed).\n"
            builds_aborted+=("$deriv_image")
            build_skip_reasons["$deriv_image"]="dependency '$base_image' failed"
        elif [[ "$scheduling_stopped" == true ]]; then
            printf "### Build \`%s\`\n\n" "$deriv_image"
            echo -e "Skipped (--fail-fast stopped scheduling).\n"
            builds_aborted+=("$deriv_image")
            build_skip_reasons["$deriv_image"]='--fail-fast stopped scheduling'
        else
            printf "### Build \`%s\`\n\n" "$deriv_image"
            local status=0
            local image_tags=""
            local local_parent_image="${base_image}:latest"
            local dockerhub_parent_image="lacledeslan/${base_image}:latest"
            local parent_image="$dockerhub_parent_image"

            if docker image inspect "$local_parent_image" > /dev/null 2>&1; then
                parent_image="$local_parent_image"
                printf "Using local parent image '%s' for '%s'.\n" "$parent_image" "$deriv_image"
            else
                printf "Local parent image '%s' is unavailable; using Docker Hub parent '%s' for '%s'.\n" "$local_parent_image" "$parent_image" "$deriv_image"
            fi

            image_tags="$(
                cd -- "${GAMESVR_ROOT}/repos/gameservers/${deriv_image}"
                PARENT_IMAGE="$parent_image" "./build-${deriv_image}.sh" "${build_options[@]}"
            )" || status=$?
            build_image_tags["$deriv_image"]="$image_tags"
            build_order+=("$deriv_image")
            report_build "$deriv_image" "$status"
        fi
    done
}

# ==============================================================================
# DECLARE GAMES AND THEIR DERIVATIVES HERE
# ==============================================================================
# Format: execute_build_pipeline "shortname" "UI Header Title" [derivatives...]

execute_build_pipeline "7daystodie"   "7 Days to Die"
execute_build_pipeline "blackmesa"     "Blackmesa"       "freeplay"
execute_build_pipeline "tf2"           "TF2"             "freeplay"
execute_build_pipeline "tf2classified" "TF2 Classified"  "freeplay"

# ==============================================================================

cleanup_built_images || image_cleanup_status=$?

####################################################################################################
## Report results
####################################################################################################

printf '## Summary\n\n'

printf "Invocation: \`%s\`  \n" "$LL_GAMESVR_BLD_COMMAND"
printf "Script version: \`%s\`  \n" "$(git -C "$GAMESVR_ROOT" rev-parse --short HEAD)"
printf 'Completed in %s seconds.\n\n' "$(($(date +%s) - "$LL_GAMESVR_BLD_START_TIME"))"

[[ ${#builds_completed[@]} -gt 0 ]] && echo -e "Successful builds: $(join_by ', ' "${builds_completed[@]}")"
[[ ${#builds_failed[@]} -gt 0 ]]    && echo -e "Failed builds:     $(join_by ', ' "${builds_failed[@]}")"
if [[ ${#builds_skipped[@]} -gt 0 ]]; then
    echo 'Skipped builds (orchestration options):'
    for skipped_build in "${builds_skipped[@]}"; do
        printf -- '- %s: %s\n' "$skipped_build" "${build_skip_reasons[$skipped_build]}"
    done
fi
if [[ ${#builds_aborted[@]} -gt 0 ]]; then
    echo 'Skipped builds (not attempted):'
    for skipped_build in "${builds_aborted[@]}"; do
        printf -- '- %s: %s\n' "$skipped_build" "${build_skip_reasons[$skipped_build]}"
    done
fi

echo -e "\n\n"

if [[ ${#builds_failed[@]} -gt 0 ]] || [[ ${#builds_aborted[@]} -gt 0 ]] || [[ "$image_cleanup_status" -ne 0 ]]; then
    exit 1
else
    exit 0
fi
