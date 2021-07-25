
#input your own conda path here! -->
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh

#move to scripts directory
cd scripts

#process flags provided
while getopts :i:t: flag; do
	case $flag in
		i) path=$OPTARG;;
		t) tools=$OPTARG;;
	esac
done

#if flags are not present, write message and quit
[ -z $path ] && echo "Please provide the path to your input folder with -i" && exit 1 
[ -z $tools ] && echo "Please provide the names of the tools you want to use with -t" && exit 1

#save list of conda envs already existing
envs=$(conda env list | awk '{print $1}' )

#run specified tools, create conda env if not yet existing
if [[ $tools = *"mlplasmids"* ]]; then
	bash run_mlplasmids.sh -i $path
fi

if [[ $tools = *"plascope"* ]]; then
	if ! [[ $envs = *"plascope"* ]]; then
		conda create --name plascope -c bioconda/label/cf201901 plascope
	conda activate plascope
	bash run_plascope.sh -i $path
fi

if [[ $tools = *"platon"* ]]; then
	if ! [[ $envs = *"platon"* ]]; then
		conda create --name platon -c bioconda platon
	conda activate platon
	bash run_platon.sh -i $path
fi

if [[ $tools = *"rfplasmid"* ]]; then
	if ! [[ $envs = *"rfplasmid"* ]]; then
		conda create --name rfplasmid -c bioconda rfplasmid
	conda activate rfplasmid
	bash run_plascope.sh -i $path
fi

#gather and combine results
conda activate base
bash gather_results.sh -t $tools
Rscript combine_results.R

