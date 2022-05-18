#!/bin/bash

###############################################
## Gnome Extentions Massive Installer (GEMI) ##
###############################################

# Default options
FORCEDEL=false
FORCECOPY=false
DIRPATH="."
YESA=false

# Options check
for opt in "$@"; do
    if [[ $opt == "-"* ]]; then
        if [[ $opt == *"d"* ]]; then FORCEDEL=true; fi
        if [[ $opt == *"h"* ]]; then help; fi
        if [[ $opt == *"c"* ]]; then FORCECOPY=true; fi
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
    ZIPARR=( $(find $DIRPATH -maxdepth 1 -name '*.zip') )
    for i in "${!ZIPARR[@]}"; do
        UUIDARR[i]="$( unzip -c -qq "${ZIPARR[i]}" metadata.json | grep uuid | cut -d \" -f4 )"
        if [ "${UUIDARR[i]}" != "" ]; then
            if [ -d "$DIRPATH/${UUIDARR[i]}" ]; then
                echo "Do you want to overwrite installed extentions? [y/n]:" 
                while ! $YESA; do
                    read -r i
                    if [[ $i == [yY] ]]; then
                        unzip -oq "${ZIPARR[i]}" -d "$HOME/.local/share/gnome-shell/extensions/${UUIDARR[i]}"
                        YESA=true
                    elif [[ $i == [nN] ]]; then
                        YESA=true
                    fi
                done
            else
                mkdir -p "$HOME/.local/share/gnome-shell/extensions/${UUIDARR[i]}"
                unzip -oq "${ZIPARR[i]}" -d "$HOME/.local/share/gnome-shell/extensions/${UUIDARR[i]}"
            fi
        elif [ "${ZIPARR[i]}" != "" ]; then echo "${ZIPARR[i]} isn't an Gnome Shell Extention"
        fi
    done
    IFS=$OLD_IFS
}

copydel
exinstaller