#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
		i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
        esac
done

#extract contig names from output
plasmid_contigs=$(cat $out_dir/ensemble_output.csv | grep '"plasmid"$' | cut -d , -f 1 | sed 's/"//g')

#write everything between contig name and next > character (including contig name)
for contig in $plasmid_contigs; do
        awk -v contig=$contig 'BEGIN {RS=">"} index($0,contig) {print ">"$0}' $input >> $out_dir/plasmid_contigs.fasta
done
