#!/bin/bash

#set -x
set -e

while getopts :i:o: flag; do
        case $flag in
		i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
        esac
done

#extract contig names from output
plasmid_contigs=$(grep '"plasmid"$' "$out_dir"/ensemble_output.csv | cut -d , -f 1 | sed 's/"//g')

#write contig name and first line after
for contig in $plasmid_contigs; do
	awk -v contig=$contig 'BEGIN {RS=">"} {ORS="";} index($0,contig)==1 {print ">"$0}' $input >> $out_dir/plasmid_contigs.fasta
done

