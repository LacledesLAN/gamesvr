#!/bin/bash

# Verify that `git` is installed
command -v git > /dev/null 2>&1 || { echo >&2 "Package 'git' required.  Aborting."; tput sgr0; exit 1; }

if [ $? -ne 0 ]; then
    echo "ERROR: git command must be installed!" | tee -a "$GAMESVR_LOGFILE";
    exit 1;
fi

# Set logfile destination if it doesn't already exist
if [ -z "$GAMESVR_LOGFILE" ]
then
    GAMESVR_LOGFILE="/dev/null"
fi

#=============================================================================================================
#
#   Clone a repo if it hasn't alread been cloned. Otherwise, fetch the latest contents if the working tree
#   is not dirty.
#
#   ARUGMENTS:
#                   1: The URL of the remote git repo to clone.
#                   2: The folder to clone the repo to.
#
#=============================================================================================================
function git_clone() {
    # REPO_URL (Parameter $1)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length1" | tee -a "$GAMESVR_LOGFILE";
        exit 1;
    elif [[ ! "$1" == *"://"* ]]; then
        echo "ERROR: parameter #1 (repository URL) must contain protocol information!" | tee -a "$GAMESVR_LOGFILE";
        exit 1;
    else
        local REPO_URL="$1";
    fi;

    # PATH_DESTINATION (Parameter $2)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length1" | tee -a "$GAMESVR_LOGFILE";
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
            echo "[$2] - Cannot update - has uncommited changes!"
        else
            echo -n "[$2] - Updating repo: "
            git -C "$PATH_DESTINATION" pull --recurse-submodules | tee -a "$GAMESVR_LOGFILE";
        fi
    else
        # PATH_DESTINATION doesn't exist
        echo -n "[$2] - Cloning..."
        git clone --recurse-submodules --quiet "$1" "$PATH_DESTINATION"
        echo "done."
    fi
}


#=============================================================================================================
#
#   Clone and/or update a git repo.
#
#   ARUGMENTS:
#                   1: The URL of the remote git repo to clone.
#                   2: The folder to clone the repo to.
#
#=============================================================================================================
function git_update() {
    # REPO_URL (Parameter $1)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #1 (repository URL) is required; cannot be zero length1" | tee -a "$GAMESVR_LOGFILE";
        exit 1;
    elif [[ ! "$1" == *"://"* ]]; then
        echo "ERROR: parameter #1 (repository URL) must contain protocol information!" | tee -a "$GAMESVR_LOGFILE";
        exit 1;
    else
        local REPO_URL="$1";
    fi;

    # PATH_DESTINATION (Parameter $2)
    if [ -z "$1" ]; then
        echo "ERROR: parameter #2 (destination path) is required; cannot be zero length1" | tee -a "$GAMESVR_LOGFILE";
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
            echo -n "[$2] - Stashing uncommited changes: "
            git -C "$PATH_DESTINATION" stash
        fi

        echo -n "[$2] - Updating repo: "
        git -C "$PATH_DESTINATION" pull --recurse-submodules | tee -a "$GAMESVR_LOGFILE";
    else
        # PATH_DESTINATION doesn't exist
        echo -n "[$2] - Cloning repo..."
        git clone --recurse-submodules --quiet "$1" "$PATH_DESTINATION"
        echo "done."
    fi
}
