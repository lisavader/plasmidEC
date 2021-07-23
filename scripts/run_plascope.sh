#!/bin/bash

#make results directory
mkdir -p ../results/plascope_predictions

#download E. coli database
mkdir -p ../databases/plascope
cd ../databases/plascope
if [[ ! -f chromosome_plasmid_db.3.cf ]]; then
	wget https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf chromosome_plasmid_db.tar.gz
	rm chromosome_plasmid_db.tar.gz
fi

run_plascope(){
cd ../../results/plascope_predictions
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run plascope on all strains in input directory
for strain in ../../$1/*.fasta
do
name=$(basename $strain .fasta)
plaScope.sh --fasta $strain -o . --db_dir ../../databases/plascope --db_name chromosome_plasmid_db --sample $name
done
}

while getopts :i: flag; do
	case $flag in
		i) path=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && exit 1

run_plascope $path
