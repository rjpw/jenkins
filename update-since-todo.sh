#!/bin/bash

# This script is a developer tool, to be used by maintainers
# to update '@since TODO' entries with actual Jenkins release versions.

set -euo pipefail

me=`basename "$0"`

IFS=$'\n'
for todo in $( git grep --line-number '@since TODO' | grep -v "$me" )
do
    #echo "TODO: $todo"
    file=$( echo $todo | cut -d : -f 1 )
    line=$( echo $todo | cut -d : -f 2 )

    echo "Analyzing $file:$line"

    lineSha=$( git blame --porcelain -L $line,$line $file | head -1 | cut -d ' ' -f 1 )
    echo -e "\tfirst sha: $lineSha"

    firstTag=$( git tag --sort=creatordate --contains $lineSha | head -1 )

    if [[ ! -z $firstTag ]]; then
        echo -e "\tfirst tag was $firstTag"
        echo -e "\tUpdating file in place"
        sedExpr="${line}s/@since TODO/@since ${firstTag//jenkins-/}/"
        sed -i.bak $sedExpr $file
    else
        echo -e "\tNot updating file, no tag found. Normal if the associated PR/commit is not merged and released yet"
    fi
done
