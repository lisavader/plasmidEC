#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
		i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
        esac
done

#extract contig names from output
plasmid_contigs=$(cat $out_dir/plasmidEC_output.csv | grep '"plasmid"$' | cut -d , -f 1 | sed 's/"//g')

#write contig name and first line after
for contig in $plasmid_contigs; do
	grep -A 1 $contig $input >> $out_dir/predicted_plasmid_contigs.fasta
done

