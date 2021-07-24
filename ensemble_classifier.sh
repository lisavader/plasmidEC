cd scripts
source /home/dla_mm/lvader/data/miniconda3/etc/profile.d/conda.sh

while getopts :i:t: flag; do
	case $flag in
		i) path=$OPTARG;;
		t) tools=$OPTARG;;
	esac
done

#check if input is present
[ -z $path ] && echo "Please provide the path to your input folder with -i" && exit 1 
[ -z $tools ] && echo "Please provide the names of the tools you want to use with -t" && exit 1


if [[ $tools = *"mlplasmids"* ]]; then
	bash run_mlplasmids.sh -i $path
fi

if [[ $tools = *"plascope"* ]]; then
	conda activate plascope
	bash run_plascope.sh -i $path
fi

if [[ $tools = *"platon"* ]]; then
	conda activate platon
	bash run_platon.sh -i $path
fi

if [[ $tools = *"rfplasmid"* ]]; then
	conda activate rfplasmid
	bash run_plascope.sh -i $path
fi

conda activate base

bash gather_results.sh -t $tools
Rscript combine_results.R

