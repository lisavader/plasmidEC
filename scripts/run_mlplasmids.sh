#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
        esac
done

#create output directory
mkdir -p $out_dir/mlplasmids_output

#clone mlplasmids
mkdir -p tools
cd tools
if [[ ! -d mlplasmids ]]; then
	echo "Cloning mlplasmids into tools..."
	git clone https://gitlab.com/sirarredondo/mlplasmids.git
else 
	echo "Found mlplasmids installation."
fi
cd mlplasmids

run_mlplasmids(){
input=$1
out_dir=$2

#run mlplasmids on input file
echo "Running mlplasmids..."
name=$(basename $input .fasta)
Rscript scripts/run_mlplasmids.R ../../$input ../../${out_dir}/mlplasmids_output/${name}.tsv 0.5 'Escherichia coli'
}

run_mlplasmids $input $out_dir
