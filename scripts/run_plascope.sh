#!/bin/bash

while getopts :i:o:t:d: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
		d) home_dir=$OPTARG;;
        esac
done

#make results directory
mkdir -p $out_dir/plascope_output

#download E. coli database
mkdir -p $home_dir/databases/plascope
if [[ ! -f $home_dir/databases/plascope/chromosome_plasmid_db.3.cf ]]; then
	echo "Downloading PlaScope E. coli database..."
	wget -P $home_dir/databases/plascope https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf $home_dir/databases/plascope/chromosome_plasmid_db.tar.gz -C $home_dir/databases/plascope
	rm $home_dir/databases/plascope/chromosome_plasmid_db.tar.gz
fi

run_plascope(){
input=$1
out_dir=$2
threads=$3

#run plascope on all strains in input directory
echo "Running PlaScope..."
name=$(basename $input .fasta)
plaScope.sh --fasta $input -o $out_dir/plascope_output --db_dir $home_dir/databases/plascope --db_name chromosome_plasmid_db --sample $name -t $threads --no-banner
}

run_plascope $input $out_dir $threads
