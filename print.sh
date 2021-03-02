#!/bin/bash

wd=$(dirname $0)

gen_ps=false
gen_pdf=false
gen_png=true


#
function usage {

    cat<<EOF>&2
  
Synopsis

  ${0} [[+-]{ps,pdf,png}] (optional current.sh args)

Description

  Overwrite the last or optionally referenced target.  Reports 'U' for
  write, and 'X' for error.

  Optionally generate ps or ps and pdf instead of the default png.

EOF

    exit 1
}

#
function compile {

    #
    if [ -z "${src}" ]
    then
	cat<<EOF>&2
$0 function compile missing parameter 'src'.
EOF
	return 1
    fi

    #
    if [ -n "$(egrep '^\\input ' ${src} )" ]
    then

	compiler='tex'

    elif [ -n "$(egrep '^\\documentclass' ${src} )" ]
    then

	compiler='latex'

    else
	cat<<EOF>&2
$0 error determining compiler for '${src}'.
EOF
	return 1
    fi

    #
    #
    echo ${compiler} ${src}

    #
    if ${compiler} ${src}
    then
	git add ${tgt_dvi}

	if [ "latex" = "${compiler}" ]
	then
	    if dvips ${tgt_dvi}
	    then

		git add ${tgt_ps}

		if ps2pdf ${tgt_ps} 
		then
		    git add ${tgt_pdf}
		else
		    return 1
		fi
	    else
		return 1
	    fi
	else
	    if ${gen_ps} && dvips ${tgt_dvi}
	    then
		git add ${tgt_ps}

		if ${gen_pdf} && ps2pdf ${tgt_ps} 
		then
		    git add ${tgt_pdf}
		fi
	    fi

	    if ${gen_png} && dvipng -p '=1' -T bbox -o ${tgt_png} ${tgt_dvi}
	    then
		git add ${tgt_png}
	    fi
	fi
	return 0
    else
	return 1
    fi
}

#
while [ -n "${1}" ]
do
    arg="${1}"
    case "${arg}" in
	+ps)
	    gen_ps=true
	    gen_pdf=false
	    gen_png=false
	    shift
	    ;;
	+pdf)
	    gen_ps=true
	    gen_pdf=true
	    gen_png=false
	    shift
	    ;;
	+png)
	    gen_png=true
	    shift
	    ;;
	-ps)
	    gen_ps=false
	    gen_pdf=false
	    gen_png=true
	    shift
	    ;;
	-pdf)
	    gen_pdf=false
	    shift
	    ;;
	-png)
	    gen_png=false
	    shift
	    ;;
	-h|-\?|--help)
	    usage
	    exit 1
	    ;;
	*)
	    break
	    ;;
    esac

done

#
src=$(${wd}/current.sh tex $* )

name=$(basename ${src} .tex)

tgt_png=${name}.png
tgt_pdf=${name}.pdf
tgt_ps=${name}.ps
tgt_dvi=${name}.dvi

#
if compile
then

    echo "U ${name}"
else

    echo "X ${name}"
fi
