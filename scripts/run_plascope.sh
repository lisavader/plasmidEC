#!/bin/bash

#set -x
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "../${BASH_SOURCE[1]}" )" &> /dev/null && pwd )

while getopts :i:o:t:d:n:s: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
		d) database_dir=$OPTARG;;
		n) plascope_database_name=$OPTARG;;
		s) species=$OPTARG;;
        esac
done

#make results directory
mkdir -p $out_dir/plascope_output

#make directory for saving pre-loaded databases
mkdir -p ${SCRIPT_DIR}/databases/plascope

#if species is E. coli
if [[ $species == 'Escherichia coli' ]]; then
if [[ ! -f ${database_dir}/${plascope_database_name}.3.cf ]]; then
	echo "Downloading PlaScope E. coli database..."
	wget -P ${database_dir} https://zenodo.org/record/1311641/files/${plascope_database_name}.tar.gz
	tar -xzf ${database_dir}/${plascope_database_name}.tar.gz -C ${database_dir}
	rm ${database_dir}/${plascope_database_name}.tar.gz
fi

#if species is K. pneumoniae
elif [[ $species == 'Klebsiella pneumoniae' ]]; then
if [[ ! -f ${database_dir}/${plascope_database_name}.3.cf ]]; then
        echo "Downloading PlaScope K. pneumoniae database..."
        wget -P ${database_dir} https://zenodo.org/record/6851206/files/K_pneumoniae_plasmid.tar.gz
        tar -xzf ${database_dir}/K_pneumoniae_plasmid.tar.gz -C ${database_dir}
        rm ${database_dir}/K_pneumoniae_plasmid.tar.gz
fi

#if species is P. aeruginosa
elif [[ $species == 'Pseudomonas aeruginosa' ]]; then
if [[ ! -f ${database_dir}/${plascope_database_name}.3.cf ]]; then
        echo "Downloading PlaScope P. aeruginosa database..."
        wget -P ${database_dir} https://zenodo.org/record/6851212/files/P_aeruginosa_plasmid.tar.gz
        tar -xzf ${database_dir}/P_aeruginosa_plasmid.tar.gz -C ${database_dir}
        rm ${database_dir}/P_aeruginosa_plasmid.tar.gz
fi

#if species is S. enterica
elif [[ $species == 'Salmonella enterica' ]]; then
echo "got the species"
if [[ ! -f ${database_dir}/${plascope_database_name}.3.cf ]]; then
        echo "Downloading PlaScope S. enterica database..."
        wget -P ${database_dir} https://zenodo.org/record/6769115/files/S_enterica_plasmid.tar.gz
        tar -xzf ${database_dir}/S_enterica_plasmid.tar.gz -C ${database_dir}
        rm ${database_dir}/S_enterica_plasmid.tar.gz
fi

#if species is S. aureus
elif [[ $species == 'Staphylococcus aureus' ]]; then
if [[ ! -f ${database_dir}/${plascope_database_name}.3.cf ]]; then
        echo "Downloading PlaScope S. enterica database..."
        wget -P ${database_dir} https://zenodo.org/record/6769599/files/S_aureus_plasmid.tar.gz
        tar -xzf ${database_dir}/S_aureus_plasmid.tar.gz -C ${database_dir}
        rm ${database_dir}/S_aureus_plasmid.tar.gz
fi
fi

run_plascope(){
input=$1
out_dir=$2
threads=$3
plascope_database_name=$4

#run plascope on all strains in input directory
echo "Running PlaScope..."
name=$(basename $input .fasta)
plaScope.sh --fasta $input -o $out_dir/plascope_output --db_dir $database_dir --db_name ${plascope_database_name} --sample $name -t $threads --no-banner
}

run_plascope $input $out_dir $threads $plascope_database_name
