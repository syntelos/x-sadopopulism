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


Synopsis

    mdb sequence

Description

    Use file 'm.db' for contents of commit messages.


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
function sequence {
    if [ -f m.db ]&& rm -f /tmp/batch
    then
        declare idx=0
        declare msg
        declare src
        declare tgt
        declare cnt=0

        while true
        do
            rm -f /tmp/batch
            cnt=0
            for mre in $(egrep -e "^${idx}:" m.db)
            do
                msg=$(echo ${mre} | awk -F: '{print $2}' | sed 's/%/ /g')
                src=$(echo ${mre} | awk -F: '{print $3}')

                # (batch interior)
                #
                if tgt=$(../target.sh "${src}") &&[ -n "${tgt}" ]
                then
                    echo ${src} >> /tmp/batch

                    # (batch op)
                    #
                    if git mv -f "${src}" "${tgt}"
                    then
                        git status --porcelain "${tgt}"
                    fi
                else
                    cat<<EOF>&2
$0 error from "../target.sh '${src}' -> '${tgt}'".
EOF
                    #(return 1) #(ignore)
                fi

                cnt=$(( ${cnt} + 1 ))
            done

            # (batch exterior)
            #
            if [ -f /tmp/batch ]&& batch=$(cat /tmp/batch) && [ -n "${batch}" ]
            then
                git commit -m "${msg}" ${batch}
            fi
            #
            if [ 0 -lt ${cnt} ]
            then
                idx=$(( ${idx} + 1 ))
            else
                break
            fi
        done
        return 0
    else
        cat<<EOF>&2
$0 error: missing resource 'm.db', or failed to vacate '/tmp/batch'.
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
        sequence)
            if sequence
            then
                exit 0
            else
                exit 1
            fi
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
