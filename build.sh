#!/bin/bash
set -euo pipefail

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

# Parse command line options
while [ "$#" -gt 0 ]
do
    case "$1" in
		# Orchestrator options.
		--delete-built-image)        orchestrator_options+=('delete-built-image') ;;
        --fast-fail)                 orchestrator_options+=('fast-fail') ;;
        --no-base|--skip-base)       orchestrator_options+=('skip-base') ;;

        # Build targets; exclusive to orchestrator. Aliases map cleanly to their core folder names
        --7days|--7daystodie)        orchestrator_build_targets+=('7daystodie') ;;
        --blackmesa)                 orchestrator_build_targets+=('blackmesa') ;;
        --tf2)                       orchestrator_build_targets+=('tf2') ;;
        --tf2c|--tf2classified)      orchestrator_build_targets+=('tf2classified') ;;

		# Build options; passed down to child scripts for Docker build customization
        --delta)                     build_options+=("--delta") ;;
        --enable-steamcmd-cache)     build_options+=("--enable-steamcmd-cache") ;;
        --disable-docker-cache)      build_options+=("--disable-docker-cache") ;;
        --skip-pull)                 build_options+=("--skip-pull") ;;
        --skip-push)                 build_options+=("--skip-push") ;;
		--skip-tests)                build_options+=("--skip-tests") ;;


		# Catch and exit if any unknown options are provided
        *)
            echo "Error: unknown option '${1}'. Exiting." >&2
            exit 12
            ;;
    esac
    shift
done

####################################################################################################
## Helper Functions
####################################################################################################

# USAGE: has_orchestrator_option "option_name"
# PURPOSE: Checks if a specific orchestration flag exists in the global 'orchestrator_options' array.
# ARGS: $1 = The string option to search for (e.g., 'fast-fail')
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

# USAGE: report_build "target_name" "exit_code"
# PURPOSE: Audits the termination status of an individual image build. Logs success, handles
#          immediate pipeline abortion on 'fast-fail', or marks it as failed for late-reporting.
# ARGS: $1 = Name of the image target that just finished building
#       $2 = Numerical exit code returned by the target's build script
# RETURNS: None (may exit script if fast-fail option is active)
function report_build {
    local target="$1"
    local exit_code="$2"

    if [ "$exit_code" -eq 0 ]; then
        builds_completed+=("$target")
    elif has_orchestrator_option 'fast-fail'; then
        echo >&2 "Build '$target' failed (Exit: $exit_code). Fast-failing script."
        exit 1
    else
        builds_failed+=("$target")
    fi
}

# USAGE: sigterm_handler
# PURPOSE: Acts as a clean-up interface triggered upon receiving termination signals (SIGINT, SIGTERM, etc.).
# ARGS: None
# RETURNS: None (exits script with code 1)
sigterm_handler() {
    echo -e "\n"
    exit 1
}

####################################################################################################
## Preflight Checks
####################################################################################################

if ! docker info &> /dev/null; then
    printf "ERROR: Docker is installed, but the current user cannot access the Docker daemon.\n" >&2
    exit 1
fi

trap 'trap " " SIGINT SIGTERM SIGHUP; kill 0; wait; sigterm_handler' SIGINT SIGTERM SIGHUP

if has_orchestrator_option 'skip-base'; then
    echo -e "Skipping base image builds.\n"
fi

####################################################################################################
## Build Engine
####################################################################################################

# Target layout printing
if [ ${#orchestrator_build_targets[@]} -eq 0 ]; then
    echo "Build target: ALL"
else
    echo "Build targets: $(join_by ', ' "${orchestrator_build_targets[@]}")"
fi

if ! has_build_option '--skip-pull'; then
    ui_header1 "pull lacledeslan/steamcmd"
    docker pull lacledeslan/steamcmd
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

    ui_header1 "$ui_name"
    ui_header2 "Fetching LL $ui_name repos"

    "${GAMESVR_ROOT}/bin/reindex-${game_id}.sh" || fail_error "Fetch $ui_name repos"

    local base_image="gamesvr-${game_id}"

    # 1. Base Build
    if ! has_orchestrator_option 'skip-base'; then
        ui_header2 "Build $base_image"

        # Note the '|| true' or explicit assignments bypass 'set -e' crashes, allowing report_build to catch it
        local status=0
        (
            cd -- "${GAMESVR_ROOT}/repos/gameservers/${base_image}"
            "./build-${base_image}.sh" "${build_options[@]}"
        ) || status=$?
        report_build "$base_image" "$status"
    fi

    # 2. Dynamic Derivative Builds
    local deriv
    for deriv in "${derivatives[@]}"; do
        local deriv_image="${base_image}-${deriv}"

        if builds_failed_includes "$base_image"; then
            ui_header2 "$deriv_image"
            echo -e "Skipped (Base image failed).\n"
            builds_aborted+=("$deriv_image")
        else
            ui_header2 "Build $deriv_image"
            local status=0
            (
                cd -- "${GAMESVR_ROOT}/repos/gameservers/${deriv_image}"
                "./build-${deriv_image}.sh" "${build_options[@]}"
            ) || status=$?
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

####################################################################################################
## Report results
####################################################################################################

ui_header1 "Results for \"$LL_GAMESVR_BLD_COMMAND\""

echo -e "\nScript version: $(git -C "$GAMESVR_ROOT" rev-parse --short HEAD)"
echo -e "Script completed in $(($(date +%s) - "$LL_GAMESVR_BLD_START_TIME")) seconds.\n"

[[ ${#builds_completed[@]} -gt 0 ]] && echo -e "Successful builds: $(join_by ', ' "${builds_completed[@]}")"
[[ ${#builds_failed[@]} -gt 0 ]]    && echo -e "Failed builds:     $(join_by ', ' "${builds_failed[@]}")"
[[ ${#builds_aborted[@]} -gt 0 ]]   && echo -e "Aborted builds:    $(join_by ', ' "${builds_aborted[@]}")"

echo -e "\n\n"

if [[ ${#builds_failed[@]} -gt 0 ]] || [[ ${#builds_aborted[@]} -gt 0 ]]; then
    exit 1
else
    exit 0
fi
