#!/bin/bash

version='0.1'

#set default values
tools='plascope,platon,rfplasmid'
threads=8
force='false'
gplas_output='false'

#load user's conda base environment
CONDA_PATH=$(conda info | grep -i 'base environment' | awk '{print $4}')
source $CONDA_PATH/etc/profile.d/conda.sh || echo "Error: Unable to load conda base environment. Is conda installed?" || exit 1

#move to scripts directory
cd scripts

#process flags provided
while getopts :i:t:o:fgtv flag; do
	case $flag in
		i) input=$OPTARG;;
		t) tools=$OPTARG;;
                o) out_dir=$OPTARG;;
		f) force='true';;
		g) gplas_output='true';;
		t) threads=$OPTARG;;
		v) echo "PlasmidEC v. $version." && exit 0;;
	esac
done

#if input or output flags are not present or input is incorrect, write message and quit
[ -z $input ] && echo "Please provide the path to your input folder (-i)" && exit 1 
[ -z $out_dir ] && echo "Please provide the name of the output directory (-o)" && exit 1
[ ! -d ../$input ] && echo "No file found at $input" && exit 1

#create output directory
if [[ -d ../$out_dir ]]; then
	if [[ $force = 'true' ]]; then	
		rm -r ../$out_dir
		mkdir ../$out_dir
	else
		printf "Output directory already exists: $out_dir\nUse the force option (-f) to overwrite.\n" && exit 1
	fi	
else
	mkdir ../$out_dir
fi

#start plasmidEC
printf "PlasmidEC v. $version.\nUsing binary classifiers: $tools.\n"

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#run specified tools, create conda env if not yet existing
if [[ $tools = *"mlplasmids"* ]]; then
	if ! [[ $envs = *"mlplasmids_ec_lv"* ]]; then
		echo "Creating conda environment mlplasmids_ec_lv..."
		conda env create --file=../yml/mlplasmids_ec_lv.yml
	fi
	conda activate mlplasmids_ec_lv
	bash run_mlplasmids.sh -i $input -o $out_dir
fi

if [[ $tools = *"plascope"* ]]; then
	if ! [[ $envs = *"plascope_ec_lv"* ]]; then
		echo "Creating conda environment plascope_ec_lv..."
		conda create --name plascope_ec_lv -c bioconda/label/cf201901 plascope
	fi
	conda activate plascope_ec_lv
	bash run_plascope.sh -i $input -o $out_dir -t $threads
fi

if [[ $tools = *"platon"* ]]; then
	if ! [[ $envs = *"platon_ec_lv"* ]]; then
		echo "Creating conda environment platon_ec_lv..."
		conda create --name platon_ec_lv -c bioconda platon=1.6
	fi
	conda activate platon_ec_lv
	bash run_platon.sh -i $input -o $out_dir -t $threads
fi

if [[ $tools = *"rfplasmid"* ]]; then
	if ! [[ $envs = *"rfplasmid_ec_lv"* ]]; then
		echo "Creating conda environment rfplasmid_ec_lv..."
		conda create --name rfplasmid_ec_lv -c bioconda rfplasmid
		conda activate rfplasmid_ec_lv
		rfplasmid --initialize
	fi
	conda activate rfplasmid_ec_lv
	bash run_rfplasmid.sh -i $input -o $out_dir -t $threads
fi

#gather and combine results
conda activate r_codes_ec_lv
bash gather_results.sh -t $tools -o $out_dir
Rscript combine_results.R $out_dir

#put results in gplas format
if [[ $gplas_output = 'true' ]]; then
	#create an environment for running r codes
	if ! [[ $envs = *"r_codes_ec_lv"* ]]; then
		echo "Creating conda environment r_codes_ec_lv..."
		conda create --name r_codes_ec_lv r=4.1
		conda activate r_codes_ec_lv
		conda install -c bioconda bioconductor-biostrings=2.60.0
		conda install -c conda-forge r-plyr=1.8.6
		conda install -c conda-forge r-dplyr=1.0.7
	fi

	#create a directory for the gplas output format
	mkdir ../$out_dir/results_gplas_format
	Rscript get_gplas_output.R ../$path $out_dir
fi
