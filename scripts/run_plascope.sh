#!/bin/bash

while getopts :i:o:t: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
        esac
done

#make results directory
mkdir -p ../$out_dir/plascope_predictions

#download E. coli database
mkdir -p ../databases/plascope
cd ../databases/plascope
if [[ ! -f chromosome_plasmid_db.3.cf ]]; then
	wget https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf chromosome_plasmid_db.tar.gz
	rm chromosome_plasmid_db.tar.gz
fi

run_plascope(){
input=$1
out_dir=$2
threads=$3
cd ../../$out_dir/plascope_predictions
#check whether input directory exists
[ ! -d ../../$input ] && exit 1
#run plascope on all strains in input directory
for strain in ../../$input/*.fasta
do
name=$(basename $strain .fasta)
plaScope.sh --fasta $strain -o . --db_dir ../../databases/plascope --db_name chromosome_plasmid_db --sample $name -t $threads --no-banner
done
}

run_plascope $input $out_dir $threads
