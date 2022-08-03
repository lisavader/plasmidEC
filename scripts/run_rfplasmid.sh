#!/bin/bash

#set -x
set -e

while getopts :i:o:t:s: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
		s) species=$OPTARG;;
        esac
done

mkdir -p $out_dir/rfplasmid_output


echo -e "\nRunning RFPlasmid..."
echo "Find logs and errors at ${out_dir}/logs/rfplasmid*"

run_rfplasmid(){
input=$1
out_dir=$2
threads=$3
species=$4

#copy file to tmp direcory (rfplasmid only takes directories as input)
mkdir $out_dir/rfplasmid_output/tmp
cp $input $out_dir/rfplasmid_output/tmp
#run rfplasmid
rfplasmid --species ${species} --input $out_dir/rfplasmid_output/tmp --jelly --threads $threads --out $out_dir/rfplasmid_output/
rm -r $out_dir/rfplasmid_output/tmp
}

run_rfplasmid $input $out_dir $threads $species 1> ${out_dir}/logs/rfplasmid_log.txt 2> ${out_dir}/logs/rfplasmid_err.txt
