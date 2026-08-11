#!/bin/bash

# Fail rather than hang when tools Git credentials require interactive input.
export GIT_TERMINAL_PROMPT=0

################################################################################
## prerequisite functions
################################################################################

# USAGE: require_command "command_name"
# PURPOSE: Verify that a required command is available in PATH.
# ARGS: $1 = Name of the command to locate.
# OUTPUTS: Write validation errors to stderr.
# RETURNS: 0 if available, 1 if unavailable, or 2 if the command name is omitted.
function require_command() {
    local command_name="${1:-}"

    if [[ -z "$command_name" ]]; then
        printf 'ERROR: A command name is required.\n' >&2
        return 2
    fi

    if ! command -v "$command_name" > /dev/null 2>&1; then
        printf "ERROR: Required command '%s' is not installed or not in PATH.\n" "$command_name" >&2
        return 1
    fi
}

################################################################################
## git functions
################################################################################

# USAGE: git_clone "repository_url" "destination_path"
# PURPOSE: Clone a missing repository or fast-forward an existing clean worktree to its configured upstream.
# ARGS: $1 = URL of the Git repository; $2 = Local destination path.
# OUTPUTS: Write a Markdown operation summary to stdout and errors to stderr.
# RETURNS: 0 on success, 2 for invalid arguments, 3 for an invalid path or worktree, 4 for local changes,
#          or 5 when a Git clone, fetch, or fast-forward operation fails.
function git_clone() {
    # REPO_URL (Parameter $1)
    if [ -z "${1:-}" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length" >&2
        return 2
    elif [[ ! "$1" == *"://"* ]]; then
        echo "ERROR: parameter #1 (repository URL) must contain protocol information!" >&2
        return 2
    fi
    local REPO_URL="$1"
    local REPOSITORY_NAME="${REPO_URL#*://}";
    REPOSITORY_NAME="${REPOSITORY_NAME#*/}";
    REPOSITORY_NAME="${REPOSITORY_NAME%/}";
    REPOSITORY_NAME="${REPOSITORY_NAME%.git}";

    # PATH_DESTINATION (Parameter $2)
    if [ -z "${2:-}" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length" >&2
        return 2
    else
        local PATH_DESTINATION;
        if ! PATH_DESTINATION=$(realpath "$2"); then
            echo "ERROR: Could not prepare destination directory: $2" >&2
            return 3
        fi
    fi

    if [[ -d "$PATH_DESTINATION" ]]
    then
        # PATH_DESTINATION exists
        local WORKTREE_ROOT;
        if ! WORKTREE_ROOT=$(git -C "$PATH_DESTINATION" rev-parse --show-toplevel 2> /dev/null); then
            echo "ERROR: [$2] exists but is not a Git working tree." >&2
            return 3
        fi

        if [[ "$WORKTREE_ROOT" != "$PATH_DESTINATION" ]]; then
            echo "ERROR: [$2] is inside, rather than the root of, a Git working tree." >&2
            return 3
        fi

        if [[ -n $(git -C "$PATH_DESTINATION" status --porcelain) ]]; then
            echo "ERROR: [$2] has local changes; refusing to continue." >&2
            git -C "$PATH_DESTINATION" status --short >&2
            return 4
        fi

        if ! git -C "$PATH_DESTINATION" fetch --quiet --prune; then
            echo "ERROR: [$2] could not fetch its upstream." >&2
            return 5
        fi

        local UPSTREAM;
        if ! UPSTREAM=$(git -C "$PATH_DESTINATION" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2> /dev/null); then
            echo "ERROR: [$2] has no configured upstream branch." >&2
            return 3
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
                echo "ERROR: [$2] cannot fast-forward to $UPSTREAM." >&2
                return 5
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
            echo "ERROR: [$2] could not be cloned from $REPO_URL." >&2
            return 5
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

# USAGE: require_executable "script_path"
# PURPOSE: Verify that a required script exists as a regular file and has its executable mode set.
# ARGS: $1 = Path of the script to validate.
# OUTPUTS: Write validation errors to stderr.
# RETURNS: 0 if executable, 2 if the script path is omitted, or 6 if the script is missing or not executable.
function require_executable() {
    local script_path="${1:-}"

    if [[ -z "$script_path" ]]; then
        printf 'ERROR: A script path is required.\n' >&2
        return 2
    fi

    if [[ ! -f "$script_path" ]]; then
        printf 'ERROR: Required script does not exist: %s\n' "$script_path" >&2
        return 6
    fi

    if [[ ! -x "$script_path" ]]; then
        printf 'ERROR: Required script is not executable: %s\n' "$script_path" >&2
        printf 'Commit the executable mode to its Git repository before retrying.\n' >&2
        return 6
    fi
}


################################################################################
## user interface functions
################################################################################

# USAGE: ui_title "title"
# PURPOSE: Configure PROMPT_COMMAND to set the terminal title before each interactive prompt.
# ARGS: $1 = Text to include in the terminal title.
# OUTPUTS: Produce no immediate output; the configured prompt command later writes a terminal escape sequence.
# RETURNS: 0 after configuring PROMPT_COMMAND.
function ui_title {
   PROMPT_COMMAND="echo -ne \"\033]0;$1 (on $HOSTNAME)\007\""
}

# USAGE: ui_header1 ["section_title"]
# PURPOSE: Write a primary section heading bounded by full-width equals-sign rules.
# ARGS: $1 = Optional section title.
# OUTPUTS: Write the formatted heading to stdout and terminal-width errors from tput to stderr.
# RETURNS: 0 on success or a nonzero status if terminal-width detection or output fails.
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

# USAGE: ui_header2 ["section_title"]
# PURPOSE: Write a secondary section heading followed by a full-width hyphen rule.
# ARGS: $1 = Optional section title.
# OUTPUTS: Write the formatted heading to stdout and terminal-width errors from tput to stderr.
# RETURNS: 0 on success or a nonzero status if terminal-width detection or output fails.
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
