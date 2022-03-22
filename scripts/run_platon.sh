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
mkdir -p $out_dir/platon_output

#download database
mkdir -p $home_dir/databases/platon
if [[ ! -d $home_dir/databases/platon/db ]]; then
	echo "Downloading Platon database..."
	wget -P $home_dir/databases/platon https://zenodo.org/record/4066768/files/db.tar.gz 
	tar -xzf $home_dir/databases/platon/db.tar.gz -C $home_dir/databases/platon
	rm $home_dir/databases/platon/db.tar.gz
fi

run_platon(){
input=$1
out_dir=$2
threads=$3

#run platon on input file
echo "Running Platon..."
name=$(basename $input .fasta)
platon --db $home_dir/databases/platon/db --output $out_dir/platon_output/$name --threads $threads $input
}

run_platon $input $out_dir $threads

