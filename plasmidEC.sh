#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version='1.1'

usage(){
cat << EOF
usage: bash plasmidEC.sh [-i INPUT] [-o OUTPUT] [options]

Mandatory arguments:
  -i INPUT		input .fasta file
  -o OUTPUT		output directory

Optional arguments:
  -h 			display this help message and exit
  -c CLASSIFIERS	classifiers to be used, in lowercase and separated by a comma (default = plascope,platon,rfplasmid)
  -t THREADS		nr. of threads used by PlaScope, Platon and RFPlasmid (default = 8)
  -p plascope DB path   Full path for a custom plascope DB. Needed for using plasmidEC with species other than E. coli 
  -d plascope DB name   Name of the custom plascope DB
  -r rfplasmid model    Name of the rfplasmid model selected. Needed for using plasmidEC with species other than E. coli (default = Enterobacteriaceae)
  -g			write gplas formatted output
  -f			force overwriting of output dir
  -v			display version nr. and exit

EOF
}

#set default values
classifiers='plascope,platon,rfplasmid'
threads=8
force='false'
gplas_output='false'
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='chromosome_plasmid_db'
rfplasmid_model='Enterobacteriaceae'

#process flags provided
while getopts :i:c:o:d:p:r:fgtvh flag; do
	case $flag in
		i) input=$OPTARG;;
		c) classifiers=$OPTARG;;
                o) out_dir=$OPTARG;;
		f) force='true';;
		g) gplas_output='true';;
                p) plascope_database_path=$OPTARG;;
		d) plascope_database_name=$OPTARG;;
		r) rfplasmid_model=$OPTARG;;
		t) threads=$OPTARG;;
		v) echo "PlasmidEC v. $version." && exit 0;;
		h) usage && exit 0;;
	esac
done

#when no flags are provided, display help message
if [ $OPTIND -eq 1 ]; then
	usage && exit 1
fi

#start plasmidEC
printf "PlasmidEC v. $version.\nUsing binary classifiers: $classifiers.\n"

#load user's conda base environment
CONDA_PATH=$(conda info | grep -i 'base environment' | awk '{print $4}')
source $CONDA_PATH/etc/profile.d/conda.sh || echo "Error: Unable to load conda base environment. Is conda installed?" || exit 1

#if input or output flags are not present or input is incorrect, write message and quit
[ -z $input ] && echo "Please provide the path to your input folder (-i)" && exit 1 
[ -z $out_dir ] && echo "Please provide the name of the output directory (-o)" && exit 1

if [[ $input == *.fasta ]]; then
	echo "Found input file at: $input"
else
	echo "Error: No .fasta file found at: $input" && exit 1
fi

#create output directory
if [[ -d $out_dir ]]; then
	if [[ $force = 'true' ]]; then	
		rm -r $out_dir
		mkdir $out_dir
	else
		printf "Output directory already exists: $out_dir\nUse the force option (-f) to overwrite.\n" && exit 1
	fi	
else
	mkdir $out_dir
fi

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#run specified tools, create conda env if not yet existing
if [[ $classifiers = *"mlplasmids"* ]]; then
	if ! [[ $envs = *"plasmidEC_mlplasmids"* ]]; then
		echo "Creating conda environment plasmidEC_mlplasmids..."
		conda env create --file=$SCRIPT_DIR/yml/plasmidEC_mlplasmids.yml --yes
	fi
	conda activate plasmidEC_mlplasmids
	bash $SCRIPT_DIR/scripts/run_mlplasmids.sh -i $input -o $out_dir -d $SCRIPT_DIR
fi

if [[ $classifiers = *"plascope"* ]]; then
	if ! [[ $envs = *"plasmidEC_plascope"* ]]; then
		echo "Creating conda environment plasmidEC_plascope..."
		conda create --name plasmidEC_plascope -c bioconda/label/cf201901 plascope=1.3.1 --yes
	fi
	conda activate plasmidEC_plascope
	bash $SCRIPT_DIR/scripts/run_plascope.sh -i $input -o $out_dir -t $threads -d ${plascope_database_path} -n ${plascope_database_name}
fi

if [[ $classifiers = *"platon"* ]]; then
	if ! [[ $envs = *"plasmidEC_platon"* ]]; then
		echo "Creating conda environment plasmidEC_platon..."
		conda create --name plasmidEC_platon -c bioconda platon=1.6 --yes
	fi
	conda activate plasmidEC_platon
	bash $SCRIPT_DIR/scripts/run_platon.sh -i $input -o $out_dir -t $threads -d $SCRIPT_DIR
fi

if [[ $classifiers = *"rfplasmid"* ]]; then
	if ! [[ $envs = *"plasmidEC_rfplasmid"* ]]; then
		echo "Creating conda environment plasmidEC_rfplasmid..."
		conda create --name plasmidEC_rfplasmid -c bioconda rfplasmid=0.0.18 --yes
		conda activate plasmidEC_rfplasmid
		rfplasmid --initialize
	fi
	conda activate plasmidEC_rfplasmid
	bash $SCRIPT_DIR/scripts/run_rfplasmid.sh -i $input -o $out_dir -t $threads -s ${rfplasmid_model}
fi

#gather and combine results
echo "Gathering results..."
bash $SCRIPT_DIR/scripts/gather_results.sh -i $input -c $classifiers -o $out_dir

#create an environment for running r codes
if ! [[ $envs = *"plasmidEC_R"* ]]; then
	echo "Creating conda environment plasmidEC_R..."
	conda create --name plasmidEC_R r=4.1 --yes
	conda activate plasmidEC_R
	conda install -c bioconda bioconductor-biostrings=2.60.0 --yes
	conda install -c conda-forge r-tidyr=1.2.0 --yes
	conda install -c conda-forge r-plyr=1.8.6 --yes
	conda install -c conda-forge r-dplyr=1.0.7 --yes
fi

conda activate plasmidEC_R
echo "Combining results..."
Rscript $SCRIPT_DIR/scripts/combine_results.R $out_dir

#put results in gplas format
if [[ $gplas_output = 'true' ]]; then	
	#create a directory for the gplas output format
	mkdir $out_dir/gplas_format
	echo "Writing gplas output..."
	Rscript $SCRIPT_DIR/scripts/write_gplas_output.R $input $out_dir
fi

#write fasta file with plasmid contigs
echo "Writing plasmid contigs..."
bash $SCRIPT_DIR/scripts/write_plasmid_contigs.sh -i $input -o $out_dir

[ -f $out_dir/ensemble_output.csv ] && echo "PlasmidEC finished. Output can be found in: $out_dir" && exit 0
