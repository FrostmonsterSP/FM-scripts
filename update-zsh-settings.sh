#!/bin/bash

# Default script's settings
LOGSTATUS=true
ECHOSTATUS=true
FORCESTATUS=false
REMOTEUPDATE=true
CREATELINKS=true
TESTMSG=false

# Custom settings container
for m in "$@"; do
    if [[ "$m" == "-"* ]]; then SETTINGS+=("${m//-/}"); fi
done

# Setting custom script's settings
for param in "${SETTINGS[@]}"; do
    if [[ "$param" == *"l"* ]] || ! [ -f "./logging.sh" ]; then LOGSTATUS=false; fi
    if [[ $param == *"e"* ]]; then ECHOSTATUS=false; fi
    if [[ $param == *"f"* ]]; then FORCESTATUS=true; ECHOSTATUS=false; fi
    if [[ $param == *"r"* ]]; then REMOTEUPDATE=false; fi
    if [[ $param == *"x"* ]]; then CREATELINKS=false; fi
    if [[ $param == *"t"* ]]; then TESTMSG=true; fi
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
        if [[ $2 == *"n"* ]]; then MSGTYPE=""; LOGPARAM="-n"; fi
    elif [[ "$2" ]]; then MSGTYPE="\e[1;34m$2:\e[0m "; LOGPARAM="$2"
    else MSGTYPE=""; LOGPARAM="";
    fi
    if $ECHOSTATUS || ( [ "$LOGPARAM" == "-e" ] && ! $FORCESTATUS ) || [ "$LOGPARAM" == "-c" ]; then echo -e "$MSGTYPE$1"; fi
    if $LOGSTATUS; then logwrite "$1" "$LOGPARAM"; fi
}

# Checking and downloading updates from repo 
update () {
    if [ -d /usr/share/zsh/core ]
        then smsg "Checking and downloading updates"; cd /usr/share/zsh/core; smsg git fetch --all; git reset --hard origin/master; smsg "Settings files downloaded"
        else smsg "zsh/core/ dirrectory haven't found" "-e"; cd /usr/share/zsh; smsg "Cloning settings from repository"; git clone --recursive https://github.com/FrostmonsterSP/FMZshConfig.git /usr/share/zsh/core | smsg; smsg "Updates checked and downloaded"
    fi || return
    smsg "Making settings scripts executable"
    chmod a+x -R /usr/share/zsh/core
    smsg "Copying settings to default dirrectory"
    cp /usr/share/zsh/core/.zshrc /etc/zsh/zshrc
    ZSHRC=$(grep -v "^startmsg" /etc/zsh/zshrc)
    echo "$ZSHRC">/etc/zsh/zshrc
    smsg "Making default settings file executable"
    chmod a+x /etc/zsh/zshrc
}

# Adds linck to core/.zshrc to users folders. Input is user folder
userlinks () {
    if [ -f /usr/share/zsh/core/.zshrc ]
        then
            smsg "Creating link in $1, user ${1//*\//}"c
            ln -sf "/usr/share/zsh/core/.zshrc" "$1/.zshrc"; #chown -h "${1//*\//}":"${1//*\//}" "$1/.zshrc"
            if [ "$(find $1 -maxdepth 1 -xtype l | grep .zshrc)" ]; then smsg "Created link is broken, try run script with \"-l\" parameter to fix it" "-e"; fi
        else
            smsg "No congiguration file in zsh/core/" "-c"; exit 1
    fi
}

# Checking .zshrc file in users folders
checkfiles () {
    if [ -L "/root/.zshrc" ];
            then smsg "Config file link in /root exists"
            else smsg "Config file link in /root doesn't exists"; userlinks "/root"
        fi
    userdirs=(/home/*)
    for userdir in "${userdirs[@]}"; do
        if [ -L "$userdir/.zshrc" ];
            then smsg "Config file link in $userdir exists"
            else smsg "Config file link in $userdir doesn't exists"; userlinks "$userdir"
        fi
    done
}

sctest () {
    smsg "Regular message"
    smsg "Custom type message" "Custom type"
    smsg "Line break message" "-n"
    smsg "Error message" "-e"
    smsg "Critical error message" "-c"
    exit 0
}

if $TESTMSG; then sctest; fi

# Root privileges checking
if [[ $EUID -ne 0 ]]; then smsg "Root privilegies requeried. Run this script under \"sudo\" or root user" "-c"; exit 0;fi

if $REMOTEUPDATE; then update; fi
if $CREATELINKS; then checkfiles; fi
if false; then schelp; fi

smsg "ZSH Settings updated" "-n"