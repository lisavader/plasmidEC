#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
                i) path=$OPTARG;;
                o) output_directory=$OPTARG;;
        esac
done

#check if input and output is provided
[ -z $output_directory ] && exit 1
[ -z $path ] && exit 1

#create output directory
mkdir -p ../$output_directory/rfplasmid_predictions

run_rfplasmid(){
path=$1
output_directory=$2
cd ../$output_directory/rfplasmid_predictions
#check whether input directory exists
[ ! -d ../../$path ] && exit 1
#run rfplasmid
rfplasmid --species Enterobacteriaceae --input ../../$path --jelly --threads 8
}

run_rfplasmid $path $output_directory
