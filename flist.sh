#!/bin/bash
#
# shell source working directory
#
wd=$(dirname $0)
#
# parameters 
#
parameters="$*"
#
# documentation
#
function usage {
    cat<<EOF>&2

Synopsis

    $0 

Description

    List existing files with default filename extension 'tex'.


    Filename extension

        $0 [a-z][a-z][a-z]

        List existing files with argument filename extension in

          {prefix}-{date}-[{subtitle}-]{index}.{ext}.


    Parameters

        $0 %p[A-Za-z_0-9]+

        List existing files with argument filename <prefix> in

          {prefix}-{date}-[{subtitle}-]{index}.{ext}


        $0 %d[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]

        List existing files with argument filename <date> in

          {prefix}-{date}-[{subtitle}-]{index}.{ext}


        $0 %s[A-Za-z_0-9]+

        List existing files with argument filename <subtitle> in

          {prefix}-{date}-[{subtitle}-]{index}.{ext}


        $0 %i[0-9]

        List existing files with argument filename <index> in

          {prefix}-{date}-[{subtitle}-]{index}.{ext}

EOF
}
for arg in ${parameters}
do
    case ${arg} in
        -h|-?)
        usage
        exit 1;;
    esac
done
#
# parameter '%p[A-Za-z_0-9]' (prefix)
#
function init_p {
    for arg in ${parameters}
    do
        case ${arg} in
            %p*)
                echo ${arg} | sed 's/%p//'
                return 0;;
        esac
    done

    if ${wd}/prefix.sh
    then
        return 0
    else
        return 1
    fi
}
component_p=$(init_p)
#
# parameter '%d[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' (date)
#
function init_d {
    for arg in ${parameters}
    do
        case ${arg} in
            %d[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
                echo ${arg} | sed 's/%d//'
                return 0;;
        esac
    done

    echo "*"
    return 0
}
component_d=$(init_d)
#
# parameter '%i[0-9]' (index)
#
function init_i {
    for arg in ${parameters}
    do
        case ${arg} in
            %i[0-9]*)
                echo ${arg} | sed 's/%i//'
                return 0;;
        esac
    done

    echo "*"
    return 0
}
component_i=$(init_i)
#
# parameter '%x[a-z][a-z][a-z]' (fext)
#
function init_x {
    #
    for arg in ${parameters}
    do
        case ${arg} in
            %x*)
                echo ${arg} | sed 's/%x//'
                return 0;;
        esac
    done
    #
    for arg in ${parameters}
    do
        case ${arg} in
            [a-z][a-z][a-z])
                echo ${arg}
                return 0;;
        esac
    done

    echo "tex"
    return 0
}
component_x=$(init_x)
#
# optional component subtitle has parameter '%s[A-Za-z_0-9]'
#
function init_s {
    for arg in ${parameters}
    do
        case ${arg} in
            %s*)
                echo ${arg} | sed 's/%s//'
                return 0;;
        esac
    done

    return 1
}

if component_s=$(init_s) &&[ -n "${component_s}" ]
then
    re=${component_p}-${component_d}-${component_s}-${component_i}.${component_x}
else
    re=${component_p}-${component_d}-${component_i}.${component_x}
fi

1>&2 echo "# 2>/dev/null ls ${re} | sort -V"

if 2>/dev/null ls ${re} | sort -V
then

    exit 0
else
    exit 1
fi
