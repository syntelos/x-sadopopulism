#!/bin/bash

prog=$0

function usage {
    cat<<EOF>&2
Synopsis

    mdb list [index|log]

Description

    Echo 'm.db' contents as indexed or (log) labelled files.


Synopsis

    mdb init

Description

    Initialize file 'm.db' for contents of working directory.


EOF
}
function init {

    if rm -f m.db
    then
        #
        # enumerate batch resource
        #
        for src in *.*
        do
            if msg=$(git log "${src}" | tail -n 1 | sed 's/^ *//; s/ /%/g;') &&[ -n "${msg}" ]
            then
                echo ${msg}:${src} >> m.db
            fi
        done
        #
        # order batch resource
        #
        if cat m.db | sort  > /tmp/m.db
        then
            rm -f m.db
            #
            lm=0; idx=0;
            #
            # index batch resource
            #
            for mre in $(cat /tmp/m.db | sed 's/ /%/g')
            do
                msg=$(echo ${mre} | awk -F: '{print $1}')
                src=$(echo ${mre} | awk -F: '{print $2}')

                if [ 0 = "${lm}" ]
                then
                    lm=${msg}
                elif [ "${lm}" != "${msg}" ]
                then
                    lm=${msg}; idx=$(( ${idx} + 1 ))
                fi
                echo ${idx}:${msg}:${src} >> m.db
            done

            return  0

        else
            cat<<EOF>&2
${prog} error: unable to sort 'm.db'.
EOF
            rm -f m.db
            return 1
        fi

    else
        cat<<EOF>&2
${prog} error: unable to truncate file 'm.db'.
EOF
        return 1
    fi
}
function list_index {
    if [ -f m.db ]
    then

        for mre in $(cat m.db)
        do

            idx=$(echo ${mre} | awk -F: '{print $1}')
            msg=$(echo ${mre} | awk -F: '{print $2}' | sed 's/%/ /g')
            src=$(echo ${mre} | awk -F: '{print $3}')

            echo ${idx} ${src}
        done
    else
        cat <<EOF>&2
$prog error: missing file 'm.db'.
EOF
        return 1
    fi
}
function list_log {
    if [ -f m.db ]
    then

        for mre in $(cat m.db | sed 's/ /%/g')
        do

            idx=$(echo ${mre} | awk -F: '{print $1}')
            msg=$(echo ${mre} | awk -F: '{print $2}' | sed 's/%/ /g')
            src=$(echo ${mre} | awk -F: '{print $3}')

            echo ${msg} ${src}
        done
    else
        cat <<EOF>&2
$prog error: missing file 'm.db'.
EOF
        return 1
    fi
}

if [ -n "${1}" ]
then
    case "${1}" in
        init)
            if init
            then
                exit 0
            else
                exit 1
            fi
            ;;
        list)
            case "${2}" in
                log)
                    if list_log
                    then
                        exit 0
                    else
                        exit 1
                    fi
                ;;
                *)
                    if list_index
                    then
                        exit 0
                    else
                        exit 1
                    fi
                ;;
            esac
            ;;
        *)
            usage
            exit 1
            ;;
    esac
else
    usage
    exit 1
fi
