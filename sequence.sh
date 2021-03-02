#!/bin/bash

#set -x
#
#
wd=$(dirname $0)
#
#
function usage {
    cat<<EOF>&2
Synopsis

    $0 [file]+ 

Description

    Move one or more <file> to target (of).


Synopsis

    $0 [dir]+ 

Description

    Move one or more <dir>/* <file> to target (of).


See also

    ./target.sh

EOF
}
#
# 
#
if [ -n "${1}" ]
then

    if [ -f "${1}" ]
    then
        while [ 0 -lt $# ]
        do
            src="${1}"
            shift
            #
            # [relocate]
            #
            if [ -f "${src}" ] && tgt=$(${wd}/target.sh "${src}")
            then
                if [ "${src}" = "${tgt}" ] || git mv -f "${src}" "${tgt}"
                then
                    git status --porcelain "${tgt}"
                else
                cat<<EOF>&2
$0 error in main: moving file <${src}> to <${tgt}>.
EOF
                    exit 1
                fi
            else
                cat<<EOF>&2
$0 error in main: file <${src}> in dir <${dir}>.
EOF
                exit 1
            fi
        done
        exit 0

    elif [ -d "${tgt}" ]
    then
        while [ 0 -lt $# ]
        do
            dir="${1}"
            shift

            if [ -d "${dir}" ]
            then

                for src in ${tgt}/*.*
                do
                    #
                    # [relocate]
                    #
                    if [ -f "${src}" ] && tgt=$(${wd}/target.sh "${src}")
                    then
                        if [ "${src}" = "${tgt}" ] ||  git mv -f "${src}" "${tgt}"
                        then
                            git status --porcelain "${tgt}"
                        else
                            cat<<EOF>&2
$0 error in main: moving file <${src}> to <${tgt}>.
EOF
                            exit 1
                        fi
                    else
                        cat<<EOF>&2
$0 error in main: file <${src}> in dir <${dir}>.
EOF
                        exit 1
                    fi
                done
            else
                cat<<EOF>&2
$0 error in main: argument <${dir}> not directory.
EOF
                exit 1
            fi
        done
        exit 0
    fi
else
    usage
    exit 1
fi
