#!/bin/bash

while getopts :i:o:t: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
        esac
done

#make results directory
mkdir -p $out_dir/plascope_output

#download E. coli database
mkdir -p databases/plascope
cd databases/plascope
if [[ ! -f chromosome_plasmid_db.3.cf ]]; then
	"Downloading PlaScope E. coli database..."
	wget https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf chromosome_plasmid_db.tar.gz
	rm chromosome_plasmid_db.tar.gz
fi
cd ../..

run_plascope(){
input=$1
out_dir=$2
threads=$3

#run plascope on all strains in input directory
echo "Running PlaScope..."
name=$(basename $input .fasta)
plaScope.sh --fasta $input -o $out_dir/plascope_output --db_dir databases/plascope --db_name chromosome_plasmid_db --sample $name -t $threads --no-banner
}

run_plascope $input $out_dir $threads
