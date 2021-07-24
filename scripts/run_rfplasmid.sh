#!/bin/bash

#create output directory
mkdir -p ../results/rfplasmid_predictions

run_rfplasmid(){
cd ../results/rfplasmid_predictions
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run rfplasmid
rfplasmid --species Enterobacteriaceae --input ../../$1 --jelly --threads 8 --out .
}

while getopts :i: flag; do
	case $flag in
		i) path=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && exit 1

run_rfplasmid $path
