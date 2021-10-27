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
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run mlplasmids on all strains in input directory
for strain in ../../$1/*.fasta
do
name=$(basename $strain .fasta)
echo "Running mlplasmids on" $name
Rscript scripts/run_mlplasmids.R $strain ../../$2/mlplasmids_predictions/${name}.tsv 0.5 'Escherichia coli'
done
}

run_mlplasmids $path $output_directory
