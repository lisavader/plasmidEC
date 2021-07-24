#!/bin/bash

#delete previous output file
rm -f ../results/all_results.csv

##MLPLASMIDS
for file in ../results/mlplasmids_predictions/*
do
tail -n +2 $file | while read line
do
prediction=$(echo $line | cut -d' ' -f3 | sed 's/"//g')
contig=$(echo $line | cut -d' ' -f4 | sed 's/"//g')
echo $contig,${prediction,,},mlplasmids >> ../results/all_results.csv
done
done

##PLASCOPE
cd ../results/plascope_predictions

files=$(ls)
for file in $files
do
cd $file

#grab chromosmal contigs
cat PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","plascope" >> ../../all_results.csv
done
#grab plasmid contigs
cat PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","plascope" >> ../../all_results.csv
done
#grab unclassified contigs
cat PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"unclassified","plascope" >> ../../all_results.csv
done

cd ..
done

cd ..

##PLATON
cd ../results/platon_predictions

files=$(ls)
for file in $files
do
cd $file

#grab chromosomal contigs
cat *chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","platon" >> ../../all_results.csv
done
#grab plasmid contigs
cat *plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","platon" >> ../../all_results.csv
done

cd ..
done

cd ..

#RFPLASMID
dir=$(ls -Art ../results/rfplasmid_predictions | tail -n 1)
tail -n +2 ../results/rfplasmid_predictions/$dir/prediction.csv | while read line
do
contig=$(echo $line | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid" >> ../results/all_results.csv
else
echo $contig,"chromosome","rfplasmid" >> ../results/all_results.csv
fi
done
