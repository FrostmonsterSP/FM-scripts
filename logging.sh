#!/bin/bash

####################
## Logging script ##
####################

sn=1 # String counter
SCRIPTID=$(echo "$0" | sed -e 's/.*\///' -e 's/\.sh//')

# Write a Log string function. Reads:
#    1) Message to log
#    2) Message type: Error(-e)/Critical(-c)/Line break (-n)/Custom
logwrite () {
    if [ -f "$LOGFILE" ]; then
        if [[ ! $(grep "$SCRIPTID"<"$LOGFILE") ]]; then echo -e "\n$sn $(date +"%Y:%j:%H:%M:%S"):   SCRIPT STARTED: $SCRIPTID" >> "$LOGFILE"; sn=$((sn+1)); fi
        NST=""
        MSGTYPE="$2: "
        case "$2" in
            -*"e") MSGTYPE="ERROR: ";;
            -*"c") MSGTYPE="CRITICAL: ";;
            -*"n") NST="\n"; sn=$((sn+1)); MSGTYPE="";;
            "") MSGTYPE=""
        esac
        echo -e "$NST$sn $(date +"%Y:%j:%H:%M:%S"):   $MSGTYPE$1" >> "$LOGFILE"
        sn=$((sn+1))
    else loginit; logwrite "$1" "$2"
    fi
}

# Logging initialization
loginit () {
    if ! [ -d .log/ ]; then mkdir .log/; fi
    LOGFILE=".log/$(date +"%Y.%j.%H.%M.%S")-$SCRIPTID.log"
    touch "$LOGFILE"; chmod +rw "$LOGFILE"
    echo -e "$sn $(date +"%Y:%j:%H:%M:%S"):   Logfile have been initialized" >> "$LOGFILE"; sn=$((sn+1))
}

loghelp () {
    printf "FM\'s Logging Script\n-------------------\nScript to print messages to the log. Should connect with other scripts. When called, it separately writes to the log the message that was given to it or an error if nothing was sent.\nStandalone running: ./logging.sh [MESSAGE] [OPTIONS]\n\nPossible options (also avalible when calling \"logwrite\" function, exept \"-h\"):\n       \"-e\": Write an error message\n       \"-c\": Write a critical error message\n       \"-n\": Adding a line break\n\"YOUR TEXT\": Set a custom type message\n       \"-h\": Prints this help\n-------------------\n"
    exit 0
}

standalone () {
    for param in "$@"; do if [ "$param" == "-h" ]; then loghelp; fi; done
    if [ "$3" ]; then echo "Too much arguments, the extra ones will be ignored."; fi
    if [[ "$1" == "-"* ]] ; then 
        local ANSWER
        printf "You enter parameter first. Are you sure you want to write it?[y/n] "
        while [ "$ANSWER" != "Y" ] && [ "$ANSWER" != "y" ]; do
            read -r ANSWER
            if [ "$ANSWER" = "N" ] || [ "$ANSWER" = "n" ]; then echo "Exit"; exit 0; fi
        done
    fi
    logwrite "$1" "$2"
    echo "Log has been written in $LOGFILE"
}

if [ "$SCRIPTID" = "logging" ]; then
    if [ -z "$1" ]; then echo "This script is not intended to be run standalone. If you want to test it, run the script with the \"-h\" option to get more information."; else standalone "$@"; fi
fi