#!/bin/bash

#if no tools combination is given, run with default
tools='platon,plascope,rfplasmid'

#load user's conda base environment
CONDA_PATH=$(conda info | grep -i 'base environment' | awk '{print $4}')
source $CONDA_PATH/etc/profile.d/conda.sh

#move to scripts directory
cd scripts

#process flags provided
while getopts :i:t:o:fg flag; do
	case $flag in
		i) path=$OPTARG;;
		t) tools=$OPTARG;;
                o) output_directory=$OPTARG;;
		f) force='true';;
		g) gplas_output='true'
	esac
done

#if input or output flags are not present or input is incorrect, write message and quit
[ -z $path ] && echo "Please provide the path to your input folder (-i)" && exit 1 
[ -z $output_directory ] && echo "Please provide the name of the output directory (-o)" && exit 1
[ ! -d ../$path ] && echo "The input folder does not exist." && exit 1

#create output directory
if [[ -d ../$output_directory ]]; then
	if [[ $force = 'true' ]]; then
		echo "Output directory will be overwritten."	
		rm -r ../$output_directory
		mkdir ../$output_directory
	else
		printf "Output directory already exists.\nIf you want to overwrite this directory use the force option (-f).\n" && exit 1
	fi	
else
	mkdir ../$output_directory
fi

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#create an environment for running r codes
if ! [[ $envs = *"r_codes_ec_lv"* ]]; then
	conda create --name r_codes_ec_lv r=4.1
	conda activate r_codes_ec_lv
	conda install -c bioconda bioconductor-biostrings=2.60.0
	conda install -c conda-forge r-plyr=1.8.6
	conda install -c conda-forge r-dplyr=1.0.7
fi

#run specified tools, create conda env if not yet existing
if [[ $tools = *"mlplasmids"* ]]; then
	if ! [[ $envs = *"mlplasmids_ec_lv"* ]]; then
		conda env create --file=../yml/mlplasmids_ec_lv.yml
	fi
	conda activate mlplasmids_ec_lv
	bash run_mlplasmids.sh -i $path -o $output_directory
fi

if [[ $tools = *"plascope"* ]]; then
	if ! [[ $envs = *"plascope_ec_lv"* ]]; then
		conda create --name plascope_ec_lv -c bioconda/label/cf201901 plascope
	fi
	conda activate plascope_ec_lv
	bash run_plascope.sh -i $path -o $output_directory
fi

if [[ $tools = *"platon"* ]]; then
	if ! [[ $envs = *"platon_ec_lv"* ]]; then
		conda create --name platon_ec_lv -c bioconda platon=1.6
	fi
	conda activate platon_ec_lv
	bash run_platon.sh -i $path -o $output_directory
fi

if [[ $tools = *"rfplasmid"* ]]; then
	if ! [[ $envs = *"rfplasmid_ec_lv"* ]]; then
		conda create --name rfplasmid_ec_lv -c bioconda rfplasmid
		conda activate rfplasmid_ec_lv
		rfplasmid --initialize
	fi
	conda activate rfplasmid_ec_lv
	bash run_rfplasmid.sh -i $path -o $output_directory
fi

#gather and combine results
conda activate r_codes_ec_lv
bash gather_results.sh -t $tools -o $output_directory
Rscript combine_results.R $output_directory

#put results in gplas format
if [[ $gplas_output = 'true' ]]; then
	#create a directory for the gplas output format
	mkdir ../$output_directory/results_gplas_format
	Rscript get_gplas_output.R ../$path $output_directory
fi
