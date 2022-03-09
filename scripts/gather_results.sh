#!/bin/bash

while getopts :i:t:o: flag; do
        case $flag in
		i) input=$OPTARG;;
                t) tools=$OPTARG;;
		o) out_dir=$OPTARG;;
        esac
done

##MLPLASMIDS
gather_mlplasmids(){
file_list=$(ls $out_dir/mlplasmids_output/ | sed 's/.tsv//g')
for file in $file_list
do
tail -n +2 $out_dir/mlplasmids_output/$file.tsv | while read line
do
prediction=$(echo $line | cut -d' ' -f3 | sed 's/"//g')
contig=$(echo $line | cut -d' ' -f4 | sed 's/"//g')
echo $contig,${prediction,,},mlplasmids,$file >> $out_dir/all_predictions.csv
done
done
}

##PLASCOPE
gather_plascope(){
results_dir=$out_dir/plascope_output/*_PlaScope

#grab chromosmal contigs
cat $results_dir/PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","plascope",$file >> $out_dir/all_predictions.csv
done
#grab plasmid contigs
cat $results_dir/PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","plascope",$file >> $out_dir/all_predictions.csv
done
#grab unclassified contigs
cat $results_dir/PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"unclassified","plascope",$file >> $out_dir/all_predictions.csv
done

}

##PLATON
gather_platon(){
results_dir=$out_dir/platon_output/*

#grab chromosomal contigs
cat $results_dir/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","platon",$file >> $out_dir/all_predictions.csv
done
#grab plasmid contigs
cat $results_dir/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","platon",$file >> $out_dir/all_predictions.csv
done

}

#RFPLASMID
gather_rfplasmid(){
dir=$(ls -Art $out_dir/rfplasmid_output | tail -n 1)
tail -n +2 $out_dir/rfplasmid_output/$dir/prediction.csv | while read line
do
#file=$(echo $line | cut -f 1 -d ',' | awk -F '_' 'BEGIN { OFS = FS }; NF { NF -= 1 }; 1' | sed 's/"//g')
contig=$(echo $line | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid",$file >> $out_dir/all_predictions.csv
else
echo $contig,"chromosome","rfplasmid",$file >> $out_dir/all_predictions.csv
fi
done
}

file=$(basename $input .fasta)

if [[ $tools = *"mlplasmids"* ]]; then
	gather_mlplasmids
fi

if [[ $tools = *"plascope"* ]]; then
	gather_plascope
fi
if [[ $tools = *"platon"* ]]; then
	gather_platon
fi
if [[ $tools = *"rfplasmid"* ]]; then
	gather_rfplasmid
fi

