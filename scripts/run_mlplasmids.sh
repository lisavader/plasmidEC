#!/bin/bash

#set -x
set -e

while getopts ":i:o:d:s:" flag; do
        case "$flag" in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		d) home_dir=$OPTARG;;
		s) species_model="${OPTARG}";;
        esac
done

species_model=$(echo "$species_model" | sed "s/'//g")

#create output directory
mkdir -p $out_dir/mlplasmids_output

#clone mlplasmids
mkdir -p $home_dir/tools/mlplasmids
if [[ ! -d $home_dir/tools/mlplasmids/scripts ]]; then
	echo "Cloning mlplasmids into tools..."
	git clone https://gitlab.com/sirarredondo/mlplasmids.git $home_dir/tools/mlplasmids
else 
	echo "Found mlplasmids installation."
fi

run_mlplasmids(){
input=$1
out_dir=$2

#run mlplasmids on input file
echo "Running mlplasmids..."
name=$(basename $input .fasta)
Rscript $home_dir/tools/mlplasmids/scripts/run_mlplasmids.R $input ${out_dir}/mlplasmids_output/${name}.tsv 0.5 "$species_model"
}

run_mlplasmids $input $out_dir
