#!/bin/bash
#
# Build Laclede's LAN game server docker images, that are too large to be built in Github actions.

####################################################################################################
## Environment
####################################################################################################

set -u;
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bin/linux/funcs.sh"
LL_GAMESVR_BLD_COMMAND="$0 $*";				# The command line used to run this script.
LL_GAMESVR_BLD_START_TIME=$(date +%s);		# The time this script started (seconds since epoch).


####################################################################################################
## Options
####################################################################################################

# Default options
option_build_targets=()		# List of targets that should be built.
option_delta_updates=false;	# Only build delta layer at the base image level?
option_fast_fail=false;		# Exit this script the first time something goes wrong?
option_skip_base=false;		# Skip base builds?

# Script vars
builds_aborted=()			# List of builds that were aborted, because of a problem.
builds_completed=()			# List of builds that completed successfully.
builds_failed=()			# List of builds that failed.


# Parse command line options
while [ "$#" -gt 0 ]
do
	case "$1" in
		# options
		-c|--cache-level)
			echo "$2"
			shift
			;;
		-d|--delta)
			option_delta_updates=true;
			;;
		--fast-fail)
			option_fast_fail=true;
			;;
		--no-base|--skip-base)
			option_skip_base=true;
			;;
		# build targets
		--blackmesa)
			option_build_targets+=('blackmesa')
			;;
		--tf2)
			option_build_targets+=('tf2')
			;;
		--tf2c|--tf2classic)
			option_build_targets+=('tf2classic')
			;;
		# unknown
		*)
			echo "Error: unknown option '${1}'. Exiting." >&2;
			exit 12;
			;;
	esac
	shift
done


####################################################################################################
## Helper Functions
####################################################################################################

# Use to check if a build has been reported as failed. Returns 0 if the build target is in the list
# of failed builds, otherwise returns 1.
# $1 The build target to check (e.g. "gamesvr-blackmesa-freeplay")
function builds_failed_includes {
	for element in in "${builds_failed[@]}"; do
		if [[ "$element" == "$1" ]]; then
			return 0;
		fi
	done
	return 1;
}

# Check if a build target is in the list of selected build targets. Returns 0 if build target was
# selected, or the build target list is empty (build everything), otherwise returns 1.
# $1 The build target to check (e.g. "blackmesa")
function build_targets_include {
	if [ ${#option_build_targets[@]} -eq 0 ]; then
		return 0;
	fi

	for element in in "${option_build_targets[@]}"; do
		if [[ "$element" == "$1" ]]; then
			return 0;
		fi
	done
	return 1;
}

function builds_aborted_add {
	ui_header2 "$1";

	echo -e "Skipped.\n";
	builds_aborted+=("$1")
}

# Reports an failure and immediately exits the script.
# $1 description of what failed.
function fail_error {
	echo >&2 "'$1' failed. Exiting.";
	exit 1;
}

# Process the results of a build.
# $1 the name of the target artifact
# $2 exit code from the build process
function report_build {
	if [ "$2" -eq 0 ]; then
		builds_completed+=("$1")
	elif [ "$option_fast_fail" = 'true' ]; then
		echo >&2 "Build '$1' failed. Exiting.";
		exit 1;
	else
		builds_failed+=("$1")
	fi
}

# Custom sigterm handler, so that interupt signals terminate the script even when a
# sub-shell is active.
sigterm_handler() {
	echo -e "\n";
	exit 1;
}


####################################################################################################
## Preflight Checks
####################################################################################################

if ! docker info > /dev/null 2>&1; then
  echo >&2 "This script required Docker. Start Docker and re-run."
  exit 1;
fi

trap 'trap " " SIGINT SIGTERM SIGHUP; kill 0; wait; sigterm_handler' SIGINT SIGTERM SIGHUP

if [ "$option_skip_base" = 'true' ]; then
	echo -e "Skipping base image builds.\n";
fi;

# Loop through all .sh files in repos directory and make them executable
for script in "$(pwd)/repos/"*.sh; do
    # Check if the file is not executable
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        echo "Made $script executable"
    fi
done


####################################################################################################
## Build
####################################################################################################

# If no build targets are specified, build all possible targets
if [ ${#option_build_targets[@]} -eq 0 ] && [ "$option_skip_base" != 'true' ]; then
    echo -ne "\n";
	echo -ne "      BUILD ALL THE TARGETS!\n"; sleep 0.01;
    echo -ne "  ─────────────────────────────▄██▄ \n";
    echo -ne "  ─────────────────────────────▀███ \n"; sleep 0.01;
    echo -ne "  ────────────────────────────────█ \n"; sleep 0.01;
    echo -ne "  ───────────────▄▄▄▄▄────────────█ \n"; sleep 0.01;
    echo -ne "  ──────────────▀▄────▀▄──────────█ \n"; sleep 0.01;
    echo -ne "  ──────────▄▀▀▀▄─█▄▄▄▄█▄▄─▄▀▀▀▄──█ \n"; sleep 0.01;
    echo -ne "  ─────────█──▄──█────────█───▄─█─█ \n"; sleep 0.01;
    echo -ne "  ─────────▀▄───▄▀────────▀▄───▄▀─█ \n"; sleep 0.01;
    echo -ne "  ──────────█▀▀▀────────────▀▀▀─█─█ \n"; sleep 0.01;
    echo -ne "  ──────────█───────────────────█─█ \n"; sleep 0.01;
    echo -ne "  ▄▀▄▄▀▄────█──▄█▀█▀█▀█▀█▀█▄────█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█────█──█████████████▄───█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█────█──██████████████▄──█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█────█───██████████████▄─█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█────█────██████████████─█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█────█───██████████████▀─█─█ \n"; sleep 0.01;
    echo -ne "  █▒▒▒▒█───██───██████████████──█─█ \n"; sleep 0.01;
    echo -ne "  ▀████▀──██▀█──█████████████▀──█▄█ \n"; sleep 0.01;
    echo -ne "  ──██───██──▀█──█▄█▄█▄█▄█▄█▀──▄█▀  \n"; sleep 0.01;
    echo -ne "  ──██──██────▀█─────────────▄▀▓█   \n"; sleep 0.01;
    echo -ne "  ──██─██──────▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──████────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──███─────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──██─────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──██────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.01;
    echo -ne "  ──██───────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌   \n"; sleep 0.01;
    echo -ne "  ──██──────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌    \n"; sleep 0.01;
    echo -ne "  ──██─────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌     \n"; sleep 0.01;
    echo -ne "  ──██────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌      \n"; sleep 0.01;
	echo -e "\n";  sleep 0.01;
    sleep 0.4;
elif [ "${#option_build_targets[@]}" -eq 1 ]; then
	echo "Build target: ${option_build_targets[0]}"
else
	printf -v joined '%s, ' "${option_build_targets[@]}"
	echo "Build targets: ${joined%,}"
fi


ui_header1 "pull lacledeslan/steamcmd";
docker pull lacledeslan/steamcmd;


## Blackmesa
build_targets_include 'blackmesa' && {
	ui_header1 "Blackmesa";

	ui_header2 "Fetching LL Blackmesa repos";
	(cd ./repos/ && ./reindex-blackmesa.sh) || fail_error "Fetch Blackmesa repos";

	# base image
	if [ "$option_skip_base" != 'true' ]; then
		ui_header2 "Build gamesvr-blackmesa";
		if [ "$option_delta_updates" = 'true' ]; then
			(cd ./repos/lacledeslan/gamesvr-blackmesa && ./build.sh --delta);
			report_build "gamesvr-blackmesa" "$?";
		else
			(cd ./repos/lacledeslan/gamesvr-blackmesa && ./build.sh);
			report_build "gamesvr-blackmesa" "$?";
		fi;
	fi;

	# derivative images
	if builds_failed_includes 'gamesvr-blackmesa'; then
		builds_aborted_add "gamesvr-blackmesa-freeplay";
	else
		ui_header2 "Build gamesvr-blackmesa-freeplay";
		(cd ./repos/lacledeslan/gamesvr-blackmesa-freeplay && ./build.sh);
		report_build "gamesvr-blackmesa-freeplay" "$?";
	fi;
}


## TF2
build_targets_include 'tf2' && {
	ui_header1 "TF2";

	ui_header2 "Fetching LL TF2 repos";
	(cd ./repos/ && ./reindex-tf2.sh) || fail_error "Fetch TF2 repos";

	if [ "$option_skip_base" != 'true' ]; then
		ui_header2 "Build gamesvr-tf2";
		if [ "$option_delta_updates" = 'true' ]; then
			(cd ./repos/lacledeslan/gamesvr-tf2 && ./build.sh --delta)
			report_build "gamesvr-tf2" "$?";
		else
			(cd ./repos/lacledeslan/gamesvr-tf2 && ./build.sh)
			report_build "gamesvr-tf2" "$?";
		fi;
	fi;

	if builds_failed_includes "gamesvr-tf2"; then
		builds_aborted_add "gamesvr-tf2-freeplay"
	else
		ui_header2 "Build gamesvr-tf2";
		(cd ./repos/lacledeslan/gamesvr-tf2-freeplay && ./build.sh)
		report_build "gamesvr-tf2-freeplay" "$?";
	fi;
}


## TF2 Classic
build_targets_include 'tf2classic' && {
	ui_header1 "TF2 Classic";

	ui_header2 "Fetching LL TF2 Classic repos";
	(cd ./repos/ && ./reindex-tf2classic.sh) || fail_error "Fetch TF2 Classic repos";

	if [ "$option_skip_base" != 'true' ]; then
		ui_header2 "Build gamesvr-tf2classic";
		(cd ./repos/lacledeslan/gamesvr-tf2classic && ./build.sh)
		report_build "gamesvr-tf2classic" "$?";
	fi;

	if builds_failed_includes "gamesvr-tf2classic"; then
		builds_aborted_add "gamesvr-tf2classic-freeplay"
	else
		ui_header2 "Build gamesvr-tf2classic-freeplay";
		(cd ./repos/lacledeslan/gamesvr-tf2classic-freeplay && ./build.sh)
		report_build "gamesvr-tf2classic-freeplay" "$?";
	fi;
}


####################################################################################################
## Report results
####################################################################################################

ui_header1 "Results for \"$LL_GAMESVR_BLD_COMMAND\"";

echo -e "\nScript version: $(git rev-parse --short HEAD)";
echo -e "Script completed in $(($(date +%s) - "$LL_GAMESVR_BLD_START_TIME")) seconds.\n";

if (( ${#builds_completed[@]} )); then
	printf -v joined '%s, ' "${builds_completed[@]}";
	echo -e "Successful builds: ${joined%,}";
fi

if (( ${#builds_failed[@]} )); then
	printf -v joined '%s, ' "${builds_failed[@]}";
	echo -e "Failed builds: ${joined%,}";
fi

if (( ${#builds_aborted[@]} )); then
printf -v joined '%s, ' "${builds_aborted[@]}";
	echo -e "Aborted builds: ${joined%,}";
fi

echo -e "\n\n";

if (( ${#builds_failed[@]} )) || (( ${#builds_aborted[@]} )); then
	exit 1;
else
	exit 0;
fi
