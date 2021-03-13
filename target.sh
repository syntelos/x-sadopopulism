#!/bin/bash

#set -x
#
# decomposition
#
declare input=''
declare target=''
declare subject=''
declare source=''
declare fext=''
#
# composition
#
reference=''

#
# 
#
function usage {
    cat<<EOF>&2
Synopsis

    $0 <file.fext>

Description

    Echo <target> filename of <file.fext>.  If <file.fext> is in
    <target> filename, then echo <file.fext>.  

See also

    ./target.sh


EOF
}
#
#
#
function decompose {
    input="${1}"
    if target=$(date -r "${input}" '+%Y%m%d-%H%M') &&[ -n "${target}" ]
    then
        if subject=$(echo "${input}" | sed 's%^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-%%; s%-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].*%%;') &&[ -n "${subject}" ]
        then
            if source=$(echo "${input}" | sed "s%^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-%%; s%${subject}-%%; s%\.[A-Za-z_~\.]*%%;") &&[ -n "${source}" ]
            then
                if fext=$(echo "${input}" | sed 's%^.*\.%%;') &&[ -n "${fext}" ]
                then
                    return 0
                else
                    cat<<EOF>&2
$0 error in decompose: string rewriting for fext.
EOF
                    return 1
                fi
            else
                cat<<EOF>&2
$0 error in decompose: string rewriting for source.
EOF
                return 1
            fi
        else
        cat<<EOF>&2
$0 error in decompose: string rewriting for subject.
EOF
            return 1
        fi
    else
        cat<<EOF>&2
$0 error in decompose: file datetime by reference.
EOF
        return 1
    fi
}
function compose {
    if [ -n "${target}" ]&&[ -n "${subject}" ]&&[ -n "${source}" ]&&[ -n "${fext}" ]
    then
        reference="${target}-${subject}-${source}.${fext}"

        return 0
    else
        cat<<EOF>&2
$0 error in compose: missing one or more terms of decomposition.
EOF
        return 1
    fi
}

#
# git:syntelos:/sh-tex$ ./target.sh 12345678-0987-subtst-12345678-0738.txt
#
if [ -n "${1}" ] 
then
    if decompose "${1}" && compose
    then
        echo "${reference}"

        exit 0
    else
        exit 1
    fi
else
    usage
    exit 1
fi
