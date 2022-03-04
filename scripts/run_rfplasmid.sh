#!/bin/bash

while getopts :i:o:t: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
        esac
done

#check if input and output is provided
[ -z $out_dir ] && exit 1
[ -z $input ] && exit 1

#create output directory
mkdir -p ../$out_dir/rfplasmid_predictions

run_rfplasmid(){
path=$1
output_directory=$2
threads=$3
cd ../$out_dir/rfplasmid_predictions
#check whether input directory exists
[ ! -d ../../$input ] && exit 1
#run rfplasmid
rfplasmid --species Enterobacteriaceae --input ../../$input --jelly --threads $threads
}

run_rfplasmid $input $out_dir $threads
