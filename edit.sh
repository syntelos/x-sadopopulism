#!/bin/bash

wd=$(dirname $0)


if file_png=$(${wd}/current.sh png $* ) &&[ -n "${file_png}" ]&&[ -f "${file_png}" ]
then

    gimp ${file_png}  &

    exit 0

elif file_tex=$(${wd}/current.sh tex $* ) &&[ -n "${file_tex}" ]&&[ -f "${file_tex}" ]
then

    emacs ${file_tex}  &

    exit 0
else
    cat<<EOF>&2
$0: file not found.
EOF
    exit 1
fi

