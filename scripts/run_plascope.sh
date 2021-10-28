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

#make results directory
mkdir -p ../$output_directory/plascope_predictions

#download E. coli database
mkdir -p ../databases/plascope
cd ../databases/plascope
if [[ ! -f chromosome_plasmid_db.3.cf ]]; then
	wget https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf chromosome_plasmid_db.tar.gz
	rm chromosome_plasmid_db.tar.gz
fi

run_plascope(){
path=$1
output_directory=$2
cd ../../$output_directory/plascope_predictions
#check whether input directory exists
[ ! -d ../../$path ] && exit 1
#run plascope on all strains in input directory
for strain in ../../$path/*.fasta
do
name=$(basename $strain .fasta)
plaScope.sh --fasta $strain -o . --db_dir ../../databases/plascope --db_name chromosome_plasmid_db --sample $name
done
}

run_plascope $path $output_directory
