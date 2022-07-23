#!/bin/bash

#set -x
set -e

while getopts ":i:l:" flag; do
        case "$flag" in
                i) input=$OPTARG;;
                l) length=$OPTARG;;
        esac
done


name="$(basename -- $input .gfa)"
dirname="$(dirname $input)"

awk '{{if($1 == "S") print ">"$1$2"_"$4"_"$5"\n"$3}}' ${input} >> ${dirname}/${name}_unfiltered.fasta 

awk -v min=${length} 'BEGIN {{RS = ">" ; ORS = ""}} length($2) >= min {{print ">"$0}}' ${dirname}/${name}_unfiltered.fasta > ${dirname}/${name}.fasta

rm ${dirname}/${name}_unfiltered.fasta
