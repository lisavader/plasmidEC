#!/bin/bash

#delete previous output file
rm -f ../results/all_results.csv

##MLPLASMIDS
gather_mlplasmids(){
for file in ../results/mlplasmids_predictions/*
do
tail -n +2 $file | while read line
do
prediction=$(echo $line | cut -d' ' -f3 | sed 's/"//g')
contig=$(echo $line | cut -d' ' -f4 | sed 's/"//g')
echo $contig,${prediction,,},mlplasmids >> ../results/${file}_all_results.csv
done
done
}

##PLASCOPE
gather_plascope(){
cd ../results/plascope_predictions

files=$(ls | sed 's/_PlaScope//g')
for file in $files
do
cd ${file}_PlaScope

#grab chromosmal contigs
cat PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","plascope" >> ../../${file}_all_results.csv
done
#grab plasmid contigs
cat PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","plascope" >> ../../${file}_all_results.csv
done
#grab unclassified contigs
cat PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"unclassified","plascope" >> ../../${file}_all_results.csv
done

cd ..
done

cd ..
}

##PLATON
gather_platon(){
cd ../results/platon_predictions

files=$(ls)
for file in $files
do
cd $file

#grab chromosomal contigs
cat *chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","platon" >> ../../${file}_all_results.csv
done
#grab plasmid contigs
cat *plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","platon" >> ../../${file}_all_results.csv
done

cd ..
done

cd ..
}

#RFPLASMID
gather_rfplasmid(){
dir=$(ls -Art ../results/rfplasmid_predictions | tail -n 1)
tail -n +2 ../results/rfplasmid_predictions/$dir/prediction.csv | while read line
do
file=$(echo $line | cut -f 1 -d ',' | awk -F '_' 'BEGIN { OFS = FS }; NF { NF -= 1 }; 1' | sed 's/"//g')
contig=$(echo $line | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid" >> ../results/${file}_all_results.csv
else
echo $contig,"chromosome","rfplasmid" >> ../results/${file}_all_results.csv
fi
done
}

while getopts :t: flag; do
	case $flag in
		t) tools=$OPTARG;;
	esac
done

#check if input is present
[ -z $tools ] && exit 1

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

#gather all outputs
cd ../results
files=$(ls *all_results.csv | sed 's/_all_results.csv//g')
for file in $files; do cat ${file}_all_results.csv | sed "s/$/\,$file/g" >> all_results.csv; done
