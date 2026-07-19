#!/bin/bash

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
#   Clone a repo if it has not already been cloned. Existing destinations must be clean Git worktrees that
#   exactly match their configured upstream branch.
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

        if ! git -C "$PATH_DESTINATION" fetch --prune; then
            echo "ERROR: [$2] could not fetch its upstream."
            exit 1;
        fi

        local UPSTREAM;
        if ! UPSTREAM=$(git -C "$PATH_DESTINATION" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2> /dev/null); then
            echo "ERROR: [$2] has no configured upstream branch."
            exit 1;
        fi

        local AHEAD_COUNT;
        local BEHIND_COUNT;
        read -r AHEAD_COUNT BEHIND_COUNT < <(git -C "$PATH_DESTINATION" rev-list --left-right --count "HEAD...$UPSTREAM")
        if [[ "$AHEAD_COUNT" != "0" || "$BEHIND_COUNT" != "0" ]]; then
            echo "ERROR: [$2] is out of sync with $UPSTREAM (ahead/behind: $AHEAD_COUNT/$BEHIND_COUNT)."
            exit 1;
        fi

        echo "[$2] - Repository is clean and synchronized with $UPSTREAM."
    else
        # PATH_DESTINATION doesn't exist
        echo -n "[$2] - Cloning..."
		git clone --recurse-submodules --quiet "$REPO_URL" "$PATH_DESTINATION"

        echo "done."
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
