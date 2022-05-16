#!/bin/bash

# Default script's settings
LOGSTATUS=false
ECHOSTATUS=true
FORCESTATUS=false

# Custom settings container
for m in "$@"; do
    if [[ "$m" == "-"* ]]; then SETTINGS+=("$m"); fi
done

# Setting custom script's settings
for param in "${SETTINGS[@]}"; do
    # Case doesn't work, I don't know why. Using if's
    if [[ "$param" == *"l"* ]] && [ -f "./logging.sh" ]; then LOGSTATUS=true; elif [[ "$param" == *"l"* ]] && ! [ -f "./logging.sh" ]; then smsg "Parameter \"l\" is set, but file \".\\logging.sh\" is not found. Logs cannot be written." "-e"; fi
    if [[ "$param" == *"e"* ]]; then ECHOSTATUS=false; fi
    if [[ "$param" == *"f"* ]]; then FORCESTATUS=true; ECHOSTATUS=false; fi
done

# Connecting "./logging.sh" if logging turned on
if $LOGSTATUS; then . ./logging.sh; fi

# Send message to log and console according script's params. Reads:
#    1) Message to log
#    2) Message type: Error(-e)/Critical(-c)/Line break (-n)/Custom
smsg () {
    if [[ $2 == "-"* ]]; then
        # Case doesn't work, I don't know why. Using if's
        if [[ $2 == *"e"* ]]; then MSGTYPE="\e[1;31mERROR:\e[0m "; LOGPARAM="-e"; fi
        if [[ $2 == *"c"* ]]; then MSGTYPE="\e[1;31mCRITICAL:\e[0m "; LOGPARAM="-c"; fi
        if [[ $2 == *"n"* ]]; then MSGTYPE="";LOGPARAM="-n"; fi
    elif [[ "$2" ]]; then MSGTYPE="\e[1;34m$2:\e[0m "; LOGPARAM="$2"
    else MSGTYPE=""; LOGPARAM="";
    fi
    if $ECHOSTATUS || ( [ "$LOGPARAM" == "-e" ] && ! $FORCESTATUS ) || [ "$LOGPARAM" == "-c" ]; then echo -e "$MSGTYPE$1"; fi
    if $LOGSTATUS; then logwrite "$1" "$LOGPARAM"; fi
}

# Checking and downloading updates from repo 
update () {
    if [ -d /usr/share/zsh/core ]
        then smsg "Checking and downloading updates"; cd /usr/share/zsh/core || return; git fetch; git pull --recurse-submodules> /dev/null 2>&1; smsg "Settings files downloaded"
        else smsg "zsh/core/ dirrectory haven't found" "-e"; smsg "Cloning settings from repository"; git clone --recursive https://github.com/FrostmonsterSP/FMZshConfig.git /usr/share/zsh/core > /dev/null 2>&1; smsg "Updates checked and downloaded"
    fi
}

# Checking .zshrc file in users folders
checkfiles () {
    if [ -f "/root/.zshrc" ];
            then smsg "Файлы есть"
            else smsg "Файлов нет"
        fi
    userdirs=(/home/*)
    for userdir in "${userdirs[@]}"; do
        if [ -f "$userdir/.zshrc" ];
            then smsg "Файлы есть"
            else smsg "Файлов нет"
        fi
    done
}

# Adds linck to core/.zshrc to users folders
userlinks () { true; }

#chmod +x -R /usr/share/zsh/core

# Root privileges checking
if [[ $EUID -ne 0 ]]; then smsg "Root privilegies requeried. Run this script under \"sudo\" or root user" "-c"; fi

update

smsg "ZSH Settings updated" "-n"