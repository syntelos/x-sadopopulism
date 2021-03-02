#!/bin/bash

mk_article=false

wd=$(dirname $0)

#
# documentation
#
function usage {
    cat<<EOF>&2
Synopsis

  $0 [-article|-short] [%component] 

Description

  Create new file "{components}.tex".

EOF
}
for arg in $*
do
    case ${arg} in
        -article)
            mk_article=true
            ;;
        -short)
            mk_article=false
            ;;
        -h|-?)
        usage
        exit 1
        ;;
    esac
done
#
#
#
if file=$(${wd}/next.sh $*) &&[ -n "${file}" ]&&[ ! -f "${file}" ]
then
    if ${mk_article}
    then
        cat<<EOF>${file}
\documentclass[12pt,a4paper]{article}
\begin{document}

\title{Logical existentialism}
\author{John D.H. Pritchard \thanks{@syntelos, logicalexistentialism@gmail.com}}
\date{\today}
\maketitle

\section{}

\end{document}
EOF
    else
        cat<<EOF>${file}
\input shorts



\bye
EOF
    fi
    echo ${file}

    git add ${file}

    emacs ${file} &
else
    usage
    exit 1
fi
