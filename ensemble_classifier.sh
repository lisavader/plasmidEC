#!/bin/bash

#input your own conda path here! -->
source ~/data/miniconda3/etc/profile.d/conda.sh

#move to scripts directory
cd scripts

#process flags provided
while getopts :i:t:o: flag; do
	case $flag in
		i) path=$OPTARG;;
		t) tools=$OPTARG;;
               # o) output_name=$OPTARG;;
	esac
done

#if flags are not present or input is incorrect, write message and quit
[ -z $path ] && echo "Please provide the path to your input folder with -i" && exit 1 
[ -z $tools ] && echo "Please provide the names of the tools you want to use with -t" && exit 1
#[ -z $output_name ] && echo "Please provide the names of the tools you want to use with -t" && exit 1
[ ! -d ../$path ] && echo "The input folder does not exist." && exit 1

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#create an environment for running r codes
if ! [[ $envs = *"r_codes_ec_lv"* ]]; then
	conda create --name r_codes_ec_lv r=4.1
	conda install -c bioconda bioconductor-biostrings=2.60.0
	conda install -c conda-forge r-plyr=1.8.6
fi

#run specified tools, create conda env if not yet existing
if [[ $tools = *"mlplasmids"* ]]; then
	if ! [[ $envs = *"mlplasmids_ec_lv"* ]]; then
		conda create --name mlplasmids_ec_lv r=3.4.1
		conda activate mlplasmids_ec_lv
		#for sucessful installation of R 3.4.1 in the HPC, I had to also install libiconv
		conda install -c conda-forge libiconv=1.16
		conda install bioconductor-biostrings=2.46.0
		conda install r-devtools r-kernlab r-seqinr r-mlr
	fi
	conda activate mlplasmids_ec_lv
	bash run_mlplasmids.sh -i $path
fi

if [[ $tools = *"plascope"* ]]; then
	if ! [[ $envs = *"plascope_ec_lv"* ]]; then
		conda create --name plascope_ec_lv -c bioconda/label/cf201901 plascope
	fi
	conda activate plascope_ec_lv
	bash run_plascope.sh -i $path
fi

if [[ $tools = *"platon"* ]]; then
	if ! [[ $envs = *"platon_ec_lv"* ]]; then
		conda create --name platon_ec_lv -c bioconda platon=1.6
	fi
	conda activate platon_ec_lv
	bash run_platon.sh -i $path
fi

if [[ $tools = *"rfplasmid"* ]]; then
	if ! [[ $envs = *"rfplasmid_ec_lv"* ]]; then
		conda create --name rfplasmid_ec_lv -c bioconda rfplasmid
		conda activate rfplasmid_ec_lv
		rfplasmid --initialize
	fi
	conda activate rfplasmid_ec_lv
	bash run_rfplasmid.sh -i $path
fi

#gather and combine results
conda activate r_codes_ec_lv
bash gather_results.sh -t $tools
#create a directory for the gplas output format
mkdir ../results_gplas_format
Rscript combine_results.R ../$path

