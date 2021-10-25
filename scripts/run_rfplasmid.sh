#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
                i) path=$OPTARG;;
                o) output_directory=$OPTARG;;
        esac
done

#check if the output directory exists
[ -z $output_directory ] && exit 1
[ -z $path ] && exit 1

#create output directory
mkdir -p ../$output_directory/rfplasmid_predictions

run_rfplasmid(){
cd ../$2/rfplasmid_predictions
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run rfplasmid
rfplasmid --species Enterobacteriaceae --input ../../$1 --jelly --threads 8
}

run_rfplasmid $path $output_directory
