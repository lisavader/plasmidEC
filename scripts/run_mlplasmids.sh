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
mkdir -p ../$output_directory/mlplasmids_predictions

#clone mlplasmids
mkdir -p ../tools
cd ../tools
if [[ ! -d mlplasmids ]]; then
	git clone https://gitlab.com/sirarredondo/mlplasmids.git
else
	echo "Mlplasmids is already installed."
fi
cd mlplasmids

run_mlplasmids(){
path=$1
output_directory=$2
#check whether input directory exists
[ ! -d ../../$path ] && exit 1
#run mlplasmids on all strains in input directory
for strain in ../../$path/*.fasta
do
name=$(basename $strain .fasta)
echo "Running mlplasmids on" $name
Rscript scripts/run_mlplasmids.R $strain ../../${output_directory}/mlplasmids_predictions/${name}.tsv 0.5 'Escherichia coli'
done
}

run_mlplasmids $path $output_directory
