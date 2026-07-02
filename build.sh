#!/bin/bash
set -euo pipefail

# Build Laclede's LAN game server docker images, that are too large to be built in Github actions.

####################################################################################################
## Environment
####################################################################################################

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/funcs.sh"
LL_GAMESVR_BLD_COMMAND="$0 $*"
LL_GAMESVR_BLD_START_TIME=$(date +%s)

####################################################################################################
## Options
####################################################################################################

build_targets=()
flow_options=()
build_options=()

# Using simple tracking arrays for cleanliness
completed_builds=()
failed_builds=()
aborted_builds=()

# Parse command line options
while [ "$#" -gt 0 ]
do
    case "$1" in
		# Build options; passed down to child scripts for Docker build customization
        -d|--delta)                  build_options+=("--delta") ;;
        --delete-built-image)        build_options+=("--delete-built-image") ;;
        --enable-steamcmd-cache)     build_options+=("--enable-steamcmd-cache") ;;
        --no-docker-cache)           build_options+=("--no-docker-cache") ;;
        --skip-pull)                 build_options+=("--skip-pull") ;;
        --skip-tests)                build_options+=("--skip-tests") ;;
        --skip-push)                 build_options+=("--skip-push") ;;

        # Flow options
        --fast-fail)                 flow_options+=('fast-fail') ;;
        --no-base|--skip-base)       flow_options+=('skip-base') ;;

        # Build targets aliases map cleanly to their core folder names
        --7days|--7daysstodie)       build_targets+=('7daysstodie') ;;
        --blackmesa)                 build_targets+=('blackmesa') ;;
        --tf2)                       build_targets+=('tf2') ;;
        --tf2c|--tf2classified)      build_targets+=('tf2classified') ;;
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

# USAGE: has_flow_option "option_name"
# PURPOSE: Checks if a specific flow control flag exists in the global 'flow_options' array.
# ARGS: $1 = The string option to search for (e.g., 'fast-fail')
# RETURNS: 0 if option is found, 1 otherwise
function has_flow_option {
    local element
    for element in "${flow_options[@]}"; do
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
# PURPOSE: Determines if a given image build has failed by checking the global 'failed_builds' array.
# ARGS: $1 = Name of the base image to check
# RETURNS: 0 if the image is in the failure list, 1 otherwise
function builds_failed_includes {
    local element
    for element in "${failed_builds[@]}"; do
        [[ "$element" == "$1" ]] && return 0
    done
    return 1
}

# USAGE: build_targets_include "game_shortname"
# PURPOSE: Determines if a specific game target should be built. If no specific targets
#          were requested via command line arguments, it assumes all targets are included.
# ARGS: $1 = Internal shortname of the game target (e.g., 'tf2')
# RETURNS: 0 if target should be built (or array is empty), 1 if target should be skipped
function build_targets_include {
    [[ ${#build_targets[@]} -eq 0 ]] && return 0
    local element
    for element in "${build_targets[@]}"; do
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
        completed_builds+=("$target")
    elif has_flow_option 'fast-fail'; then
        echo >&2 "Build '$target' failed (Exit: $exit_code). Fast-failing script."
        exit 1
    else
        failed_builds+=("$target")
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

for cmd in git docker; do
    if ! command -v "$cmd" &> /dev/null; then
        printf "ERROR: %s is not installed or not in your PATH.\n" "${cmd^}" >&2
        exit 1
    fi
done

if ! docker info &> /dev/null; then
    printf "ERROR: Docker is installed, but the current user cannot access the Docker daemon.\n" >&2
    exit 1
fi

trap 'trap " " SIGINT SIGTERM SIGHUP; kill 0; wait; sigterm_handler' SIGINT SIGTERM SIGHUP

if has_flow_option 'skip-base'; then
    echo -e "Skipping base image builds.\n"
fi

# Ensure all scripts are executable
for script in "$(pwd)/repos/"*.sh; do
    [ -e "$script" ] || continue
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "Made $script executable"
    fi
done

####################################################################################################
## Build Engine
####################################################################################################

# Target layout printing
if [ ${#build_targets[@]} -eq 0 ]; then
    echo "Build target: ALL"
else
    echo "Build targets: $(join_by ', ' "${build_targets[@]}")"
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

    ! build_targets_include "$game_id" && return 0

    ui_header1 "$ui_name"
    ui_header2 "Fetching LL $ui_name repos"

    (cd ./repos/ && "./reindex-${game_id}.sh") || fail_error "Fetch $ui_name repos"

    local base_image="gamesvr-${game_id}"

    # 1. Base Build
    if ! has_flow_option 'skip-base'; then
        ui_header2 "Build $base_image"

        # Note the '|| true' or explicit assignments bypass 'set -e' crashes, allowing report_build to catch it
        local status=0
        (cd "./repos/lacledeslan/$base_image" && ./build.sh "${build_options[@]}") || status=$?
        report_build "$base_image" "$status"
    fi

    # 2. Dynamic Derivative Builds
    local deriv
    for deriv in "${derivatives[@]}"; do
        local deriv_image="${base_image}-${deriv}"

        if builds_failed_includes "$base_image"; then
            ui_header2 "$deriv_image"
            echo -e "Skipped (Base image failed).\n"
            aborted_builds+=("$deriv_image")
        else
            ui_header2 "Build $deriv_image"
            local status=0
            (cd "./repos/lacledeslan/$deriv_image" && ./build.sh "${build_options[@]}") || status=$?
            report_build "$deriv_image" "$status"
        fi
    done
}

# ==============================================================================
# DECLARE GAMES AND THEIR DERIVATIVES HERE
# ==============================================================================
# Format: execute_build_pipeline "shortname" "UI Header Title" [derivatives...]

execute_build_pipeline "7daysstodie"   "7 Days to Die"
execute_build_pipeline "blackmesa"     "Blackmesa"       "freeplay"
execute_build_pipeline "tf2"           "TF2"             "freeplay"
execute_build_pipeline "tf2classified" "TF2 Classified"  "freeplay"

# ==============================================================================

####################################################################################################
## Report results
####################################################################################################

ui_header1 "Results for \"$LL_GAMESVR_BLD_COMMAND\""

echo -e "\nScript version: $(git rev-parse --short HEAD)"
echo -e "Script completed in $(($(date +%s) - "$LL_GAMESVR_BLD_START_TIME")) seconds.\n"

[[ ${#completed_builds[@]} -gt 0 ]] && echo -e "Successful builds: $(join_by ', ' "${completed_builds[@]}")"
[[ ${#failed_builds[@]} -gt 0 ]]    && echo -e "Failed builds:     $(join_by ', ' "${failed_builds[@]}")"
[[ ${#aborted_builds[@]} -gt 0 ]]   && echo -e "Aborted builds:    $(join_by ', ' "${aborted_builds[@]}")"

echo -e "\n\n"

if [[ ${#failed_builds[@]} -gt 0 ]] || [[ ${#aborted_builds[@]} -gt 0 ]]; then
    exit 1
else
    exit 0
fi
