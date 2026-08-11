#!/bin/bash

# Fail rather than hang when tools Git credentials require interactive input.
export GIT_TERMINAL_PROMPT=0

################################################################################
## git functions
################################################################################

# Verify that `git` is installed
if ! command -v git > /dev/null 2>&1; then
    echo >&2 "Package 'git' required. Aborting."
    exit 1
fi

#=============================================================================================================
#
#   Clone a repo if it has not already been cloned. Existing destinations must be clean Git worktrees with a
#   configured upstream branch; clean branches that are behind their upstream are fast-forwarded.
#
#   ARGUMENTS:
#                   1: The URL of the remote git repo to clone.
#                   2: The folder to clone the repo to.
#
#=============================================================================================================
function git_clone() {
    # REPO_URL (Parameter $1)
    if [ -z "${1:-}" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length1";
        exit 1;
    elif [[ ! "$1" == *"://"* ]]; then
        echo "ERROR: parameter #1 (repository URL) must contain protocol information!";
        exit 1;
    fi;
    local REPO_URL="$1";
    local REPOSITORY_NAME="${REPO_URL#*://}";
    REPOSITORY_NAME="${REPOSITORY_NAME#*/}";
    REPOSITORY_NAME="${REPOSITORY_NAME%/}";
    REPOSITORY_NAME="${REPOSITORY_NAME%.git}";

    # PATH_DESTINATION (Parameter $2)
    if [ -z "${2:-}" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length1";
        exit 123;
    else
        local PATH_DESTINATION;
        if ! PATH_DESTINATION=$(realpath "$2"); then
            echo "Could not prepare destination directory";
            exit 1;
        fi
    fi;

    if [[ -d "$PATH_DESTINATION" ]]
    then
        # PATH_DESTINATION exists
        local WORKTREE_ROOT;
        if ! WORKTREE_ROOT=$(git -C "$PATH_DESTINATION" rev-parse --show-toplevel 2> /dev/null); then
            echo "ERROR: [$2] exists but is not a Git working tree."
            exit 1;
        fi

        if [[ "$WORKTREE_ROOT" != "$PATH_DESTINATION" ]]; then
            echo "ERROR: [$2] is inside, rather than the root of, a Git working tree."
            exit 1;
        fi

        if [[ -n $(git -C "$PATH_DESTINATION" status --porcelain) ]]; then
            echo "ERROR: [$2] has local changes; refusing to continue."
            git -C "$PATH_DESTINATION" status --short
            exit 1;
        fi

        if ! git -C "$PATH_DESTINATION" fetch --quiet --prune; then
            echo "ERROR: [$2] could not fetch its upstream."
            exit 1;
        fi

        local UPSTREAM;
        if ! UPSTREAM=$(git -C "$PATH_DESTINATION" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2> /dev/null); then
            echo "ERROR: [$2] has no configured upstream branch."
            exit 1;
        fi

        local PREVIOUS_REVISION;
        PREVIOUS_REVISION=$(git -C "$PATH_DESTINATION" rev-parse --short HEAD)
        local BEHIND_COUNT;
        BEHIND_COUNT=$(git -C "$PATH_DESTINATION" rev-list --right-only --count "HEAD...$UPSTREAM")

        if [[ "$BEHIND_COUNT" == "0" ]]; then
            local CURRENT_REVISION;
            local COMMIT_COUNT;
            local TRACKED_FILE_COUNT;
            CURRENT_REVISION=$(git -C "$PATH_DESTINATION" rev-parse --short HEAD)
            COMMIT_COUNT=$(git -C "$PATH_DESTINATION" rev-list --count HEAD)
            TRACKED_FILE_COUNT=$(git -C "$PATH_DESTINATION" ls-files | wc -l | tr -d ' ')

            printf '### %s\n\n' "$REPOSITORY_NAME"
            printf -- '- Already up to date with `%s` at `%s` (%s commits; %s tracked files).\n\n' "$UPSTREAM" "$CURRENT_REVISION" "$COMMIT_COUNT" "$TRACKED_FILE_COUNT"
        else
            if ! git -C "$PATH_DESTINATION" merge --quiet --ff-only "$UPSTREAM"; then
                echo "ERROR: [$2] cannot fast-forward to $UPSTREAM."
                exit 1;
            fi

            local CURRENT_REVISION;
            local CHANGE_STATISTICS;
            CURRENT_REVISION=$(git -C "$PATH_DESTINATION" rev-parse --short HEAD)
            CHANGE_STATISTICS=$(git -C "$PATH_DESTINATION" diff --shortstat "$PREVIOUS_REVISION..HEAD")

            printf '### %s\n\n' "$REPOSITORY_NAME"
            printf -- '- Updated `%s` from `%s` to `%s` by fast-forwarding %s commits.\n' "$UPSTREAM" "$PREVIOUS_REVISION" "$CURRENT_REVISION" "$BEHIND_COUNT"
            if [[ -n "$CHANGE_STATISTICS" ]]; then
                printf -- '- Changes: %s.\n\n' "$CHANGE_STATISTICS"
            else
                printf -- '- Changes: no file changes.\n\n'
            fi
        fi
    else
        # PATH_DESTINATION doesn't exist
        if ! git clone --recurse-submodules --quiet "$REPO_URL" "$PATH_DESTINATION"; then
            echo "ERROR: [$2] could not be cloned from $REPO_URL."
            exit 1;
        fi

        local RELATIVE_DESTINATION;
        local UPSTREAM;
        local CURRENT_REVISION;
        local COMMIT_COUNT;
        local TRACKED_FILE_COUNT;
        RELATIVE_DESTINATION=$(realpath --relative-to="$PWD" "$PATH_DESTINATION")
        UPSTREAM=$(git -C "$PATH_DESTINATION" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')
        CURRENT_REVISION=$(git -C "$PATH_DESTINATION" rev-parse --short HEAD)
        COMMIT_COUNT=$(git -C "$PATH_DESTINATION" rev-list --count HEAD)
        TRACKED_FILE_COUNT=$(git -C "$PATH_DESTINATION" ls-files | wc -l | tr -d ' ')

        printf '### %s\n\n' "$REPOSITORY_NAME"
        printf -- '- Created local directory: `%s`.\n' "$RELATIVE_DESTINATION"
        printf -- '- Cloned `%s` at `%s` (%s commits; %s tracked files).\n\n' "$UPSTREAM" "$CURRENT_REVISION" "$COMMIT_COUNT" "$TRACKED_FILE_COUNT"
    fi
}

function require_executable() {
    local script_path="${1:-}"

    if [[ ! -f "$script_path" ]]; then
        printf 'ERROR: Required script does not exist: %s\n' "$script_path" >&2
        exit 1
    fi

    if [[ ! -x "$script_path" ]]; then
        printf 'ERROR: Required script is not executable: %s\n' "$script_path" >&2
        printf 'Commit the executable mode to its Git repository before retrying.\n' >&2
        exit 1
    fi
}


################################################################################
## user interface functions
################################################################################

# Set the terminal title
# $1 The title to set
function ui_title {
   PROMPT_COMMAND="echo -ne \"\033]0;$1 (on $HOSTNAME)\007\""
}

# Display a inline header 1, used for breaking up script output
# $1 (optional) The section title
function ui_header1() {
    echo -e "\n";

    {
        echo -e "\n";
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;

        if [[ -n $1 ]]; then
            echo -e "$1";
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
        fi
    }
}

# Display a inline header 2, used for breaking up script output
# $1 (optional) The section title
function ui_header2() {
    echo -e "\n";

    {
        echo -e "\n";

        if [[ -n $1 ]]; then
            echo -e "$1";
        fi

		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
    }
}
