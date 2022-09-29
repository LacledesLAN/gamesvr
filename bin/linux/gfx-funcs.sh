#!/bin/bash

function gfx_allthethings() {
    echo -ne "\n";
    echo -ne "  ─────────────────────────────▄██▄ \n"; sleep 0.018;
    echo -ne "  ─────────────────────────────▀███ \n"; sleep 0.018;
    echo -ne "  ────────────────────────────────█ \n"; sleep 0.018;
    echo -ne "  ───────────────▄▄▄▄▄────────────█ \n"; sleep 0.018;
    echo -ne "  ──────────────▀▄────▀▄──────────█ \n"; sleep 0.018;
    echo -ne "  ──────────▄▀▀▀▄─█▄▄▄▄█▄▄─▄▀▀▀▄──█ \n"; sleep 0.018;
    echo -ne "  ─────────█──▄──█────────█───▄─█─█ \n"; sleep 0.018;
    echo -ne "  ─────────▀▄───▄▀────────▀▄───▄▀─█ \n"; sleep 0.018;
    echo -ne "  ──────────█▀▀▀────────────▀▀▀─█─█ \n"; sleep 0.018;
    echo -ne "  ──────────█───────────────────█─█ \n"; sleep 0.018;
    echo -ne "  ▄▀▄▄▀▄────█──▄█▀█▀█▀█▀█▀█▄────█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█──█████████████▄───█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█──██████████████▄──█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█───██████████████▄─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█────██████████████─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█────█───██████████████▀─█─█ \n"; sleep 0.018;
    echo -ne "  █▒▒▒▒█───██───██████████████──█─█ \n"; sleep 0.018;
    echo -ne "  ▀████▀──██▀█──█████████████▀──█▄█ \n"; sleep 0.018;
    echo -ne "  ──██───██──▀█──█▄█▄█▄█▄█▄█▀──▄█▀  \n"; sleep 0.018;
    echo -ne "  ──██──██────▀█─────────────▄▀▓█   \n"; sleep 0.018;
    echo -ne "  ──██─██──────▀█▀▄▄▄▄▄▄▄▄▄▀▀▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──████────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──███─────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██──────────█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██─────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██────────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█   \n"; sleep 0.018;
    echo -ne "  ──██───────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌   \n"; sleep 0.018;
    echo -ne "  ──██──────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌    \n"; sleep 0.018;
    echo -ne "  ──██─────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌     \n"; sleep 0.018;
    echo -ne "  ──██────▐█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▌      \n"; sleep 0.018;
    sleep 0.30;
    return 0;
}

# Start a section of output on the screen
# $1 (optional) The section title
# $2 (optional) The foreground color to use during this section
function gfx_section_start() {
    echo -e "\n";

    tput sgr0; tput bold;

    {
        echo -e "\n";
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;        # print line across terminal width

        if [[ -n $1 ]]; then
            echo -e "$1";
            printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =;
        fi
    }

    # Set optional foreground color
    tput sgr0; tput dim; tput setaf "$2";

    return 0;
}

function gfx_section_end() {
    tput sgr0;
    return 0;
}
