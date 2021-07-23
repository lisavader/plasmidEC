#!/bin/bash

#create output directory
mkdir -p ../results/mlplasmids_predictions

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
Rscript scripts/run_mlplasmids.R $strain ../../results/mlplasmids_predictions/${name}.tsv 1e-5 'Escherichia coli'
done
}

while getopts :i: flag; do
	case $flag in
		i) path=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && exit 1

run_mlplasmids $path
