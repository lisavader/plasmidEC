#!/bin/bash

while getopts :i:o:p flag; do
        case $flag in
                i) path=$OPTARG;;
                o) output_directory=$OPTARG;;
		p) parallel=TRUE
        esac
done

#check if input and output is provided
[ -z $output_directory ] && exit 1
[ -z $path ] && exit 1

#make results directory
mkdir -p ../$output_directory/platon_predictions

#download database
mkdir -p ../databases/platon
cd ../databases/platon
if [[ ! -d db ]]; then
	wget https://zenodo.org/record/4066768/files/db.tar.gz
	tar -xzf db.tar.gz
	rm db.tar.gz
fi

run_platon(){
path=$1
output_directory=$2

cd ../../$output_directory/platon_predictions

#check whether input directory exists
[ ! -d ../../$path ] && exit 1

#run platon on all strains in input directory
for strain in ../../$path/*.fasta
do
name=$(basename $strain .fasta)
echo "Running platon on" $name
platon --db ../../databases/platon/db --output $name --threads 8 $strain
done
}

run_platon_parallel(){
path=$1
output_directory=$2

cd ../../$output_directory

#check whether input directory exists
[ ! -d ../$path ] && exit 1

#build scripts
mkdir -p platon_scripts

for strain in ../$path/*.fasta
do
name=$(basename $strain .fasta)
echo "#!/bin/bash
cd ../platon_predictions
platon --db ../../databases/platon/db --output $name --threads 8 ../$strain" > platon_scripts/${name}.sh
done

#execute scripts
cd platon_scripts
for script in $(ls *.sh); do
echo "Running platon script" ${script}"..."
sbatch --time 1:00:00 --mem 5G -c 8 $script
done
}


if [[ $parallel = TRUE ]]; then
	run_platon_parallel $path $output_directory
else	
	run_platon $path $output_directory
fi
