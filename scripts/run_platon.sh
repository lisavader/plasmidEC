#!/bin/bash

while getopts :i:o:t: flag; do
        case $flag in
                i) input=$OPTARG;;
                o) out_dir=$OPTARG;;
		t) threads=$OPTARG;;
        esac
done

#make results directory
mkdir -p $out_dir/platon_output

#download database
mkdir -p databases/platon
cd databases/platon
if [[ ! -d db ]]; then
	echo "Downloading Platon database..."
	wget https://zenodo.org/record/4066768/files/db.tar.gz
	tar -xzf db.tar.gz
	rm db.tar.gz
fi

run_platon(){
input=$1
out_dir=$2
threads=$3

cd ../..

#run platon on input file
echo "Running platon..."
name=$(basename $input .fasta)
platon --db databases/platon/db --output $out_dir/platon_output/$name --threads $threads $input
}

run_platon $input $out_dir $threads

