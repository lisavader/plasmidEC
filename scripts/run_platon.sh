#!/bin/bash

while getopts :i:o:t: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
        esac
done

#make results directory
mkdir -p ../$out_dir/platon_predictions

#download database
mkdir -p ../databases/platon
cd ../databases/platon
if [[ ! -d db ]]; then
	wget https://zenodo.org/record/4066768/files/db.tar.gz
	tar -xzf db.tar.gz
	rm db.tar.gz
fi

run_platon(){
input=$1
out_dir=$2
threads=$3

cd ../../$out_dir/platon_predictions

#check whether input directory exists
[ ! -d ../../$input ] && exit 1

#run platon on all strains in input directory
for strain in ../../$input/*.fasta
do
name=$(basename $strain .fasta)
echo "Running platon on" $name
platon --db ../../databases/platon/db --output $name --threads $threads $strain
done
}

run_platon $input $out_dir $threads

