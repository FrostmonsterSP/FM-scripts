#!/bin/bash

###############################################
## Gnome Extentions Massive Installer (GEMI) ##
###############################################

# Default options
FORCEDEL=false
DIRPATH="."

# Options check
for opt in "$@"; do
    if [[ $opt == "-"* ]]; then
        if [[ $opt == *"d"* ]]; then FORCEDEL=true
        elif [[ $opt == *"h"* ]]; then help
        fi
    fi
    if [[ $opt == *"/"* ]] && [[ $opt != "-"* ]]; then DIRPATH=$opt; fi
done

# Delete copies
copydel () {
    if [[ "$(find "$DIRPATH" -type f -name "*(*).zip")" ]]; then
        if ! $FORCEDEL; then
            printf "Delete copies? [y/n]: "
            local d
            while [ "$d" != "Y" ] && [ "$d" != "y" ] && [ "$d" != "N" ] && [ "$d" != "n" ]; do
                read -r d
                if [[ "$d" == [yY] ]]; then
                    find "$DIRPATH" -type f -name "*(*).zip" -delete
                fi
            done
        else find "$DIRPATH" -type f -name "*(*).zip" -delete
        fi
    fi
}

exinstaller () {
    OLD_IFS="$IFS"; IFS=$'\n';
    ZIPARR=( $(find $DIRPATH -name '*.zip') )
    for i in "${!ZIPARR[@]}"; do
        UUIDARR[i]=$( unzip -c "${ZIPARR[i]}" metadata.json | grep uuid | cut -d \" -f4 )
        mkdir -p "$HOME/.local/share/gnome-shell/extensions/${UUIDARR[i]}"
        # ZIPARR=( $(find . -name '*.zip') )
        unzip -q "${ZIPARR[i]}" -d "$HOME/.local/share/gnome-shell/extensions/${UUIDARR[i]}"
        # gnome-extensions install "${ZIPARR[i]}"
    done
    IFS=$OLD_IFS
}

copydel
exinstaller