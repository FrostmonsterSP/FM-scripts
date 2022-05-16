#!/bin/bash

####################
## Logging script ##
####################

sn=1 # String counter

# Write a Log string function. Reads:
#    1) Message to log
#    2) Message type: Error(-e)/Critical(-c)/Line break (-n)/Custom
logwrite () {
    if [ -f "$LOGFILE" ]; then
        if [ "$(cat "$LOGFILE" | grep -q "$SCRIPTID" )" ]; then false; fi
        NST=""
        MSGTYPE="$2: "
        case "$2" in
            -*"e") MSGTYPE="ERROR: ";;
            -*"c") MSGTYPE="CRITICAL: ";;
            -*"n") NST="\n"; sn=$((sn+1)); MSGTYPE="";;
            "") MSGTYPE=""
        esac
        echo -e "$NST $(date +"%Y:%j:%H:%M:%S") $sn:   $MSGTYPE$1" >> "$LOGFILE"
        sn=$((sn+1))
    else loginit
    fi
}

# Logging initialization
loginit () {
    if ! [ -d .log/ ]; then mkdir .log/; fi
    SCRIPTID="$(echo "$0" | sed -e 's/\.\///' -e 's/\.sh//')"
    LOGFILE=".log/$(date +"%Y.%j.%H.%M.%S")-$SCRIPTID.log"
    touch "$LOGFILE"; chmod +rw "$LOGFILE"
    logwrite "Logfile have been initialized"
}