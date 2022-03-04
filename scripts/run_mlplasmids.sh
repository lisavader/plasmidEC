#!/bin/bash

while getopts :i:o: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
        esac
done

#create output directory
mkdir -p ../$out_dir/mlplasmids_output

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
input=$1
out_dir=$2
#check whether input directory exists
[ ! -d ../../$input ] && exit 1
#run mlplasmids on all strains in input directory
for strain in ../../$input/*.fasta
do
name=$(basename $strain .fasta)
echo "Running mlplasmids on" $name
Rscript scripts/run_mlplasmids.R $strain ../../${out_dir}/mlplasmids_predictions/${name}.tsv 0.5 'Escherichia coli'
done
}

run_mlplasmids $input $out_dir
