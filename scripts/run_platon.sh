#!/bin/bash

#make results directory
mkdir ../results/platon_predictions

#download database
mkdir -p ../databases/platon
cd ../databases/platon
if [[ ! d db ]]; then
	wget https://zenodo.org/record/4066768/files/db.tar.gz
	tar -xzf db.tar.gz
	rm db.tar.gz
fi

run_platon(){
cd ../results/platon_predictions
#check whether input directory exists
[ ! -d ../../$1 ] && exit 1
#run platon on all strains in input directory
for strain in ../../$1/*.fna
do
name=$(basename $strain .fna)
platon --db ../../databases/platon/db --output $name --threads 8 $strain
done
}
