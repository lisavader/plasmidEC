#!/bin/bash

#set -x
set -e

while getopts :i:c:o: flag; do
        case $flag in
		i) input=$OPTARG;;
                c) classifiers=$OPTARG;;
		o) out_dir=$OPTARG;;
        esac
done

##MLPLASMIDS
gather_mlplasmids(){
file_list=$(ls $out_dir/mlplasmids_output/ | sed 's/.tsv//g')
for file in $file_list
do
if [ -f $out_dir/mlplasmids_output/$file.tsv ]; then
tail -n +2 $out_dir/mlplasmids_output/$file.tsv | while read line
do
prediction=$(echo "$line" | cut -f3 | sed 's/"//g')
contig=$(echo "$line" | cut -f4 | cut -f1 -d, | sed 's/"//g')
echo $contig,${prediction,,},mlplasmids,$file >> $out_dir/all_predictions.csv
done
else
echo "mlplasmids output couldn't be found" && exit 1
fi
done
}

##PLASCOPE
gather_plascope(){
results_dir=$out_dir/plascope_output/*_PlaScope
#go to extended result file to find contig ID and class nr
if [ -f $results_dir/Centrifuge_results/*extendedresult ]; then
cat $results_dir/Centrifuge_results/*extendedresult | sed '1d' | while read line
do
contig=$(echo "$line" | cut -f1)
class_nr=$(echo "$line" | cut -f3)
#translate class nr to classification (i.e. 2 = chromosome, 3 = plasmid, 0 / 1 = unclassified)
if [ $class_nr == '3' ]; then
	classification="plasmid"
elif [ $class_nr == '2' ]; then
	classification="chromosome"
elif [ $class_nr == '0' ] || [ $class_nr == '1' ]; then
	classification="unclassified"
fi
#write to file
echo $contig,$classification,"plascope",$file >> $out_dir/all_predictions.csv
done
else
echo "PlaScope output couldn't be found. Check ${results_dir}/Centrifuge_results/centrifuge.log for issues" && exit 1
fi
}

##PLATON
gather_platon(){
results_dir=$out_dir/platon_output/*
#grab chromosomal contigs
if [ -f $results_dir/*chromosome.fasta ]; then
cat $results_dir/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo "$line" | cut -c 2-)
echo $contig,"chromosome","platon",$file >> $out_dir/all_predictions.csv
done
#grab plasmid contigs
cat $results_dir/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo "$line" | cut -c 2-)
echo $contig,"plasmid","platon",$file >> $out_dir/all_predictions.csv
done
else
echo "Platon output couldn't be found" && exit 1
fi
}

#RFPLASMID
gather_rfplasmid(){
dir=$(ls -Art $out_dir/rfplasmid_output | tail -n 1)
if [ -f $out_dir/rfplasmid_output/$dir/prediction.csv ]; then 
tail -n +2 $out_dir/rfplasmid_output/$dir/prediction.csv | while read line
do
#file=$(echo "$line" | cut -f 1 -d ',' | awk -F '_' 'BEGIN { OFS = FS }; NF { NF -= 1 }; 1' | sed 's/"//g')
contig=$(echo "$line" | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid",$file >> $out_dir/all_predictions.csv
else
echo $contig,"chromosome","rfplasmid",$file >> $out_dir/all_predictions.csv
fi
done
else
echo "RFPlasmids output was not found. Did you select a valid species model?" && exit 1
fi
}

file=$(basename $input .fasta)

if [[ $classifiers = *"mlplasmids"* ]]; then
	gather_mlplasmids
fi

if [[ $classifiers = *"plascope"* ]]; then
	gather_plascope
fi
if [[ $classifiers = *"platon"* ]]; then
	gather_platon
fi
if [[ $classifiers = *"rfplasmid"* ]]; then
	gather_rfplasmid
fi

