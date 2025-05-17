#!/bin/bash

################################################################################
## git functions
################################################################################

# Verify that `git` is installed
command -v git > /dev/null 2>&1 || { echo >&2 "Package 'git' required.  Aborting."; tput sgr0; exit 1; }

if [ $? -ne 0 ]; then
    echo "ERROR: git command must be installed!" | tee -a "$GAMESVR_LOGFILE";
    exit 1;
fi

#=============================================================================================================
#
#   Clone a repo if it hasn't already been cloned. Otherwise, fetch the latest contents if the working tree
#   is not dirty.
#
#   ARGUMENTS:
#                   1: The URL of the remote git repo to clone.
#                   2: The folder to clone the repo to.
#
#=============================================================================================================
function git_clone() {
    # REPO_URL (Parameter $1)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length1";
        exit 1;
    elif [[ ! "$1" == *"://"* ]]; then
        echo "ERROR: parameter #1 (repository URL) must contain protocol information!";
        exit 1;
    else
        local REPO_URL="$1";
    fi;

    # PATH_DESTINATION (Parameter $2)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length1";
        exit 123;
    else
        local PATH_DESTINATION;
        PATH_DESTINATION=$(realpath "$2");

        if [ $? -ne 0 ]; then
            echo "Could not prepare destination directory";
            exit 1;
        fi
    fi;

    if [[ -d "$PATH_DESTINATION" ]]
    then
        # PATH_DESTINATION exists
        if [[ $(git -C "$PATH_DESTINATION" diff --stat) != '' ]]; then
            echo "[$2] - Cannot update - has uncommitted changes!"

			for i in {6..1}
			do
  				echo -ne "\rProceeding in $i..."
  				sleep 1;
			done
        else
            echo -n "[$2] - Updating repo: "
            git -C "$PATH_DESTINATION" pull --recurse-submodules;
        fi
    else
        # PATH_DESTINATION doesn't exist
        echo -n "[$2] - Cloning..."
		git clone --recurse-submodules --quiet "$1" "$PATH_DESTINATION"

		# Set the fileMode to false, to prevent file permissions changes from being tracked
		git config --file "$PATH_DESTINATION/.git/config" core.fileMode false

        echo "done."
    fi
}


#=============================================================================================================
#
#   Clone and/or update a git repo.
#
#   ARGUMENTS:
#                   1: The URL of the remote git repo to clone.
#                   2: The folder to clone the repo to.
#
#=============================================================================================================
function git_update() {
    # REPO_URL (Parameter $1)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length1";
        exit 1;
    else
		git ls-remote "$1" > /dev/null 2>&1

		if [ "$?" -ne 0 ]; then
    		echo "[ERROR] Unable to read from '$1'. Invalid or unreachable Git repository."
    		exit 1;
		else
    		echo "[SUCCESS] Repository '$1' is accessible."
		fi

        local REPO_URL="$1";
    fi;

    # PATH_DESTINATION (Parameter $2)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length1";
        exit 123;
    else
        local PATH_DESTINATION;
        PATH_DESTINATION=$(realpath "$2");

        if [ $? -ne 0 ]; then
            echo "Could not prepare destination directory";
            exit 1;
        fi
    fi;


    if [[ -d "$PATH_DESTINATION" ]]
    then
        # PATH_DESTINATION exists

		if ! git -C "$PATH_DESTINATION" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    		echo "'$PATH_DESTINATION' already exists but is not a git repository."
			echo "Unable to clone or update the repository '$REPO_URL'."
    		exit 1;
		fi

        if [[ $(git -C "$PATH_DESTINATION" diff --stat) != '' ]]; then
            echo -n "[$2] - Stashing uncommitted changes: "
            git -C "$PATH_DESTINATION" stash
        fi

        echo -n "[$2] - Updating repo: "
        git -C "$PATH_DESTINATION" pull --recurse-submodules;

		return;
	fi;

	# PATH_DESTINATION doesn't exist
	echo -n "[$2] - Cloning repo..."
	git clone --recurse-submodules --quiet "$1" "$PATH_DESTINATION"
	echo "done."
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
