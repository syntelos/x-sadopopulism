#!/bin/bash

if p=$(pwd | sed 's%.*/tex-%%; s%/.*%%') &&[ -n "${p}" ]
then
    echo ${p}
    exit 0
else
    echo prefix
    exit 1
fi
