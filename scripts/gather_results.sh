#!/bin/bash

while getopts :t:o: flag; do
        case $flag in
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
cd $out_dir/plascope_output

files=$(ls | sed 's/_PlaScope//g')
for file in $files
do
cd ${file}_PlaScope

#grab chromosmal contigs
cat PlaScope_predictions/*chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","plascope",$file >> ../../all_predictions.csv
done
#grab plasmid contigs
cat PlaScope_predictions/*plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","plascope",$file >> ../../all_predictions.csv
done
#grab unclassified contigs
cat PlaScope_predictions/*unclassified.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"unclassified","plascope",$file >> ../../all_predictions.csv
done

cd ..
done

cd ..
}

##PLATON
gather_platon(){
cd $out_dir/platon_output

files=$(ls)
for file in $files
do
cd $file

#grab chromosomal contigs
cat *chromosome.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"chromosome","platon",$file >> ../../all_predictions.csv
done
#grab plasmid contigs
cat *plasmid.fasta | grep '>' | while read line
do
contig=$(echo $line | cut -c 2-)
echo $contig,"plasmid","platon",$file >> ../../all_predictions.csv
done

cd ..
done

cd ..
}

#RFPLASMID
gather_rfplasmid(){
dir=$(ls -Art $out_dir/rfplasmid_output | tail -n 1)
tail -n +2 $out_dir/rfplasmid_output/$dir/prediction.csv | while read line
do
file=$(echo $line | cut -f 1 -d ',' | awk -F '_' 'BEGIN { OFS = FS }; NF { NF -= 1 }; 1' | sed 's/"//g')
contig=$(echo $line | cut -d, -f5 | sed 's/"//g')
if [[ $line = *'"p"'* ]]; then
echo $contig,"plasmid","rfplasmid",$file >> $out_dir/all_predictions.csv
else
echo $contig,"chromosome","rfplasmid",$file >> $out_dir/all_predictions.csv
fi
done
}


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

