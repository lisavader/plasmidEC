#!/bin/bash

#set -x
#set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

version='1.1'

usage(){
cat << EOF
usage: bash plasmidEC.sh [-i INPUT] [-o OUTPUT] [options]

Mandatory arguments:
  -i INPUT		input .fasta or .gfa file.
  -o OUTPUT		output directory.

Optional arguments:
  -h 			Display this help message and exit.
  -c CLASSIFIERS	Classifiers to be used, in lowercase and separated by a comma. 
  -s SPECIES		Select one of the pre-loaded species ("Escherichia coli", "Klebsiella pneumoniae", "Acinetobacter baumannii", "Salmonella enterica", "Pseudomonas aeruginosa", "Enterococcus faecium", "Enterococcus faecalis", "Staphylococcus aureus").
  -l LENGTH 		Minimum length of contigs to be classified (default=1000)
  -t THREADS		nr. of threads used by PlaScope, Platon and RFPlasmid (default = 8).
  -p PLASCOPE DB PATH   Full path for a custom plascope DB. Needed for using plasmidEC with species other than pre-loaded species. Not compatible with -s.
  -d PLASCOPE DB NAME   Name of the custom plascope DB. Not compatible with -s.
  -r RFPLASMID MODEL    Name of the rfplasmid model selected. Needed for using plasmidEC with species other than pre-loaded species. Not compatible with -s.
  -g			Write gplas formatted output.
  -m                    Use minority vote to classify contigs as plasmid-derived.
  -f			Force overwriting of output dir.
  -v			Display version nr. and exit.

EOF
}

#set default values
classifiers='plascope,platon,rfplasmid'
threads=8
force='false'
gplas_output='false'

#process flags provided
while getopts :i:c:o:d:p:s:r:l:fgtvhm flag; do
	case $flag in
		i) input=$OPTARG;;
		c) classifiers=$OPTARG;;
		s) species=$OPTARG;;
                o) out_dir=$OPTARG;;
    l) length=$OPTARG;;
		f) force='true';;
		g) gplas_output='true';;
		m) minority_vote='true';;
                p) plascope_database_path=$OPTARG;;
		d) plascope_database_name=$OPTARG;;
		r) rfplasmid_model=$OPTARG;;
		t) threads=$OPTARG;;
		v) echo "PlasmidEC v. $version." && exit 0;;
		h) usage && exit 0;;
	esac
done

#Establish default values according to species selected
if [[ $species == 'Escherichia coli' ]]; then 
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='chromosome_plasmid_db'
rfplasmid_model='Enterobacteriaceae'
classifiers='plascope,platon,rfplasmid'
echo "You have selected the Escherichia coli as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Klebsiella pneumoniae' ]]; then
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='K_pneumoniae_plasmid_db'
rfplasmid_model='Enterobacteriaceae'
classifiers='plascope,platon,rfplasmid'
echo "You have selected Klebsiella pneumoniae as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Acinetobacter baumannii' ]]; then
plascope_database_path=${SCRIPT_DIR}/databases/plascope
#plascope_database_name='abaumannii_plasmid_db'
rfplasmid_model='Generic'
classifiers='rfplasmid,platon,mlplasmids'
mlplasmids_model="'""Acinetobacter baumannii""'"
echo "You have selected Acinetobacter baumannii as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Pseudomonas aeruginosa' ]]; then
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='P_aeruginosa_plasmid_db'
rfplasmid_model='Pseudomonas'
echo "You have selected Pseudomonas aeruginosa as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Enterococcus faecalis' ]]; then
#plascope_database_path=${SCRIPT_DIR}/databases/plascope
#plascope_database_name='E_faecalis_plasmid_db'
rfplasmid_model='Enterococcus'
classifiers='rfplasmid,platon,mlplasmids'
mlplasmids_model="'""Enterococcus faecalis""'"
echo "You have selected Enterococcus faecalis as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Enterococcus faecium' ]]; then
#plascope_database_path=${SCRIPT_DIR}/databases/plascope
#plascope_database_name='E_faecium_plasmid'
rfplasmid_model='Enterococcus'
classifiers='rfplasmid,platon,mlplasmids'
mlplasmids_model="'""Enterococcus faecium""'"
echo "You have selected Enterococcus faecium as a species; flags -p , -d and -r will be ignored"

elif [[ $species == 'Salmonella enterica' ]]; then
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='S_enterica_plasmid_db'
rfplasmid_model='Generic'
echo "You have selected Salmonella enterica as a species; -p , -d and -r flags will be ignored"

elif [[ $species == 'Staphylococcus aureus' ]]; then
plascope_database_path=${SCRIPT_DIR}/databases/plascope
plascope_database_name='S_aureus_plasmid_db'
rfplasmid_model='Staphylococcus'
echo "You have selected Staphylococcus aureus as a species; flags -p , -d and -r will be ignored"

else
echo "You have not selected a preloaded species; -p , -d and -r flags are mandatory"
#Check for flags (-p, -d and -r).
[ -z $plascope_database_path ] && echo "Please provide the path to the directory that contains the PlaScope DB (-p)" && exit 1
[ -z $plascope_database_name ] && echo "Please provide the name of the PlaScope DB file (-d)" && exit 1
[ -z $rfplasmid_model ] && echo "Please provide the name of the RFPlasmid model you want to use (-r). Available models can be found in: https://github.com/aldertzomer/RFPlasmid/blob/master/specieslist.txt" && exit 1

#clean the plascope_DB_directory from trailing slash
plascope_database_path=$(echo ${plascope_database_path} | sed 's#/*$##g')

#check if the plascope_db directory exists
if [[ -d $plascope_database_path ]]; then
echo "Plascope DB directory exists"
else
echo "Plascope DB directory does not exists, or path is incorrect" && exit 1
fi

if [[ -f ${plascope_database_path}/${plascope_database_name}.1.cf ]]; then
echo "Plascope DB file exists"
else
echo "Plascope DB file does not exists or name is incorrect" && exit 1
fi
fi

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

#Check if input file is fasta or gfa format
if [[ $input == *.fasta ]]; then
	echo "Found input file at: $input"
	format="fasta"
	name="$(basename -- $input .fasta)"
elif [[ $input == *.gfa ]]; then
  echo "Found input file at: $input"
  echo "The file is in .gfa format. plasmidEC will convert it to FASTA format."
  format="gfa"
  name="$(basename -- $input .gfa)"
  echo ${name}
  else
	echo "Error: No .fasta or .gfa file found at: $input" && exit 1
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

#---Filter by length, move and (if required) convert format of input file.---
#Check if length is a valid value
if [[ -d $length ]]; then
  #check if length is a positive value
  if [ "$length" > 0 ]; then
    echo "You have selected to filter-out contigs smaller than: "${length}
  else
    echo "You have selected an invalid value for -l. Please select a positive integer"
  fi
else
  echo "PlasmidEC will classify only contigs larger than 1000bp. You can select a different cut-off using the -l flag"
  length=1000
fi

#filter and move
bash $SCRIPT_DIR/scripts/extract_nodes.sh -i ${input} -o ${out_dir} -l ${length} -f ${format}

#change the input to a new one
input=${out_dir}/${name}.fasta
echo ${input}

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#run specified tools, create conda env if not yet existing
if [[ $classifiers = *"mlplasmids"* ]]; then
	if ! [[ $envs = *"plasmidEC_mlplasmids"* ]]; then
		echo "Creating conda environment plasmidEC_mlplasmids..."
		conda env create --file=$SCRIPT_DIR/yml/plasmidEC_mlplasmids.yml
	fi
	conda activate plasmidEC_mlplasmids
	bash $SCRIPT_DIR/scripts/run_mlplasmids.sh -i $input -o $out_dir -d $SCRIPT_DIR -s "$mlplasmids_model"
fi

if [[ $classifiers = *"plascope"* ]]; then
	if ! [[ $envs = *"plasmidEC_plascope"* ]]; then
		echo "Creating conda environment plasmidEC_plascope..."
		conda create --name plasmidEC_plascope -c bioconda/label/cf201901 plascope=1.3.1 --yes
		conda activate plasmidEC_plascope
		conda install centrifuge=1.0.3=py36pl5.22.0_3 -c bioconda --yes
	fi
	conda activate plasmidEC_plascope
	bash $SCRIPT_DIR/scripts/run_plascope.sh -i $input -o $out_dir -t $threads -d ${plascope_database_path} -n ${plascope_database_name} -s "$species"
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

#Combine results and create final output
#Check if minority vote option has been selected
if [[ $minority_vote = 'true' ]]; then
    plasmid_limit=0
    echo "You have selected the -m flag. Minority vote for classifying contigs as plasmid will be applied"
else
    plasmid_limit=1
fi

conda activate plasmidEC_R
echo "Combining results..."
Rscript $SCRIPT_DIR/scripts/combine_results.R $out_dir $plasmid_limit $classifiers

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

[ -f $out_dir/ensemble_output.csv ] && echo "PlasmidEC finished successfully. Output can be found in: $out_dir" && exit 0
