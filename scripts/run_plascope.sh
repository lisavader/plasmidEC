#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "../${BASH_SOURCE[1]}" )" &> /dev/null && pwd )

while getopts :i:o:t:d:n: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
		d) home_dir=$OPTARG;;
		n) plascope_database_name=$OPTARG;;
        esac
done

#make results directory
mkdir -p $out_dir/plascope_output

#download E. coli database
mkdir -p ${SCRIPT_DIR}/databases/plascope
if [[ ! -f ${SCRIPT_DIR}/databases/plascope/chromosome_plasmid_db.3.cf ]]; then
	echo "Downloading PlaScope E. coli database..."
	wget -P ${SCRIPT_DIR}/databases/plascope https://zenodo.org/record/1311641/files/chromosome_plasmid_db.tar.gz
	tar -xzf ${SCRIPT_DIR}/databases/plascope/chromosome_plasmid_db.tar.gz -C ${SCRIPT_DIR}/databases/plascope/
	rm ${SCRIPT_DIR}/databases/plascope/chromosome_plasmid_db.tar.gz
fi

run_plascope(){
input=$1
out_dir=$2
threads=$3
plascope_database_name=$4

#run plascope on all strains in input directory
echo "Running PlaScope..."
name=$(basename $input .fasta)
plaScope.sh --fasta $input -o $out_dir/plascope_output --db_dir $home_dir --db_name ${plascope_database_name} --sample $name -t $threads --no-banner
}

run_plascope $input $out_dir $threads $plascope_database_name
