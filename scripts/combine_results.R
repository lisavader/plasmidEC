library(plyr)
library(Biostrings)
library(dplyr)

##get the directory which contains the fasta files from the arguments on the command line.
arguments = commandArgs(trailingOnly=TRUE)
input_directory=arguments[1]
output_directory=arguments[2]

#list all the fasta files in the input directory
all_files=list.files(path=input_directory)

#create an empty dataframe for containing the results
contig_lengths<-data.frame(Contig_name=character(0),Contig_length=integer(0))

#loop thru all files and extract the name of the contig and the length
for (genomes in all_files) {
  file_path<-paste(input_directory,'/',genomes,sep='')
  fasta_parsed<-readDNAStringSet(filepath = file_path,format='fasta' )
  Contig_name<-as.character(names(fasta_parsed))
  Contig_length<-as.integer(lengths(fasta_parsed))
  tmp_df<-data.frame(Contig_name,Contig_length)
  contig_lengths<-rbind(contig_lengths,tmp_df)
}

##Load results
all_results_path<-paste("../",output_directory,"/all_results.csv",sep='')
all_results <- read.csv(all_results_path, header = FALSE)
names(all_results) <- c("Contig_name","prediction","software","genome_id")

##Process each software
mlplasmids <- all_results[all_results$software=='mlplasmids',]
mlplasmids <- mlplasmids[,-c(3)]
names(mlplasmids) <- c("Contig_name","mlplasmids","genome_id")

platon <- all_results[all_results$software=='platon',]
platon <- platon[,-c(3)]
names(platon) <- c("Contig_name","platon","genome_id")

plascope <- all_results[all_results$software=='plascope',]
plascope <- plascope[,-c(3)]
names(plascope) <- c("Contig_name","plascope","genome_id")

rfplasmid <- all_results[all_results$software=='rfplasmid',]
rfplasmid <- rfplasmid[,-c(3)]
names(rfplasmid) <- c("Contig_name","rfplasmid","genome_id")

##Combine results
combined <- merge(merge(mlplasmids,platon,all = TRUE),merge(rfplasmid,plascope, all = TRUE),all = TRUE)
combined <- combined[, colSums(is.na(combined)) != nrow(combined)] #remove column of non-included tool
#replace NA of mlplasmids with 'chromosome'.if the column exists
if("mlplasmids" %in% colnames(combined)) {
  combined$mlplasmids<-ifelse(is.na(combined$mlplasmids),'chromosome',as.character(combined$mlplasmids));
}

##Assign plasmid if called by more than one of the tools
combined$plasmid_count <- apply(combined, 1, function(x) length(which(x=="plasmid")))
combined$classification <- "chromosome"
combined$classification[combined$plasmid_count>1] <- "plasmid"

##Write output file
combined_path<-paste('../',output_directory,'/plasmidEC_output.csv',sep='')
write.csv(combined,combined_path,row.names = FALSE)

##write gplas output
gplas_output<-combined
#get the prob of being a chromosome - for cases of plascope unclassified, this will provide a probability of 0.5 if split decision.
gplas_output$Prob_Chromosome<-ifelse(gplas_output$plascope=='unclassified', round((2-as.numeric(gplas_output$plasmid_count))/2,2), round((3-as.numeric(gplas_output$plasmid_count))/3,2))
#get the probability of being a plasmid
gplas_output$Prob_Plasmid<-ifelse(gplas_output$plascope=='unclassified', round((as.numeric(gplas_output$plasmid_count))/2,2), round((as.numeric(gplas_output$plasmid_count))/3,2))
#cases in which prob=0.5 are named as plasmid.
gplas_output$classification<-ifelse(gplas_output$Prob_Plasmid==0.5,'Plasmid',as.character(gplas_output$classification))
##replace with capital letter the predictions
gplas_output$classification<-gsub(gplas_output$classification, pattern="plasmid", replacement="Plasmid")
gplas_output$classification<-gsub(gplas_output$classification, pattern="chromosome", replacement="Chromosome")
#combine with contig-lengths
gplas_output<-join(gplas_output,contig_lengths)

#create output
#1. get the names of the strains in a list
strain_names_list <- vector(mode = "list")
for (row in 1:nrow(gplas_output)){
  strain_names_list<-append(strain_names_list,as.character(gplas_output[row,2]))

}
strain_names_list<-unique(strain_names_list)

# create data_frames
for (genome in strain_names_list) {
  individual_gplas<-filter(gplas_output,gplas_output$genome_id==genome)
  individual_gplas_ordered<-individual_gplas[,c(8,9,7,1)]
  names(individual_gplas_ordered)<-c('Prob_Chromosome','Prob_Plasmid','Prediction','Contig_name')
  individual_gplas_ordered<-join(individual_gplas_ordered,contig_lengths)
  output_path<-paste('../',output_directory,'/results_gplas_format/',genome,'_plasmid_prediction.tab',sep='')
  write.table(individual_gplas_ordered,output_path,row.names = FALSE, sep='\t')
}

