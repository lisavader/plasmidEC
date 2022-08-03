#!/bin/bash

#set -x
set -e

while getopts ":i:l:o:f:" flag; do
        case "$flag" in
                i) input=$OPTARG;;
                l) length=$OPTARG;;
                o) out_dir=$OPTARG;;
		f) format=$OPTARG;;
        esac
done

if [ "$format" == 'gfa' ]; then
name="$(basename -- $input .gfa)"
awk '{{if($1 == "S") print ">"$1$2"_"$4"_"$5"\n"$3}}' ${input} >> ${out_dir}/${name}_unfiltered.fasta 
awk -v min=${length} 'BEGIN {{RS = ">" ; ORS = ""}} length($2) >= min {{print ">"$0}}' ${out_dir}/${name}_unfiltered.fasta > ${out_dir}/${name}.fasta
rm ${out_dir}/${name}_unfiltered.fasta
else
name="$(basename -- $input .fasta)"
awk -v min=${length} 'BEGIN {{RS = ">[^\n]+\n" ; ORS = ""}} length() >= min {printf "%s", prt $0} {prt = RT}' ${input} > ${out_dir}/${name}.fasta
fi
