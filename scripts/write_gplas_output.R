suppressMessages(library(plyr))
suppressMessages(library(Biostrings))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))

##get the directory which contains the fasta files from the arguments on the command line.
arguments = commandArgs(trailingOnly=TRUE)
input_path=arguments[1]
output_directory=arguments[2]

#load results file
combined_path<-paste(output_directory,'/ensemble_output.csv',sep='')
combined <- read.csv(combined_path)

##write gplas output
gplas_output<-combined

if ("PlaScope" %in% colnames(gplas_output)){
gplas_output$Prob_Chromosome<-ifelse(gplas_output$PlaScope=='unclassified', round((2-as.numeric(gplas_output$Plasmid_count))/2,2), round((3-as.numeric(gplas_output$Plasmid_count))/3,2))
#get the probability of being a plasmid
gplas_output$Prob_Plasmid<-ifelse(gplas_output$PlaScope=='unclassified', round((as.numeric(gplas_output$Plasmid_count))/2,2), round((as.numeric(gplas_output$Plasmid_count))/3,2))
#cases in which prob=0.5 are named as plasmid.
gplas_output$Combined_prediction<-ifelse(gplas_output$Prob_Plasmid==0.5,'Plasmid',as.character(gplas_output$Combined_prediction))
} else {
gplas_output$Prob_Chromosome<-round((3-as.numeric(gplas_output$Plasmid_count))/3,2)
gplas_output$Prob_Plasmid<-round((as.numeric(gplas_output$Plasmid_count))/3,2)
}
##replace with capital letter the predictions
gplas_output$Combined_prediction<-gsub(gplas_output$Combined_prediction, pattern="plasmid", replacement="Plasmid")
gplas_output$Combined_prediction<-gsub(gplas_output$Combined_prediction, pattern="chromosome", replacement="Chromosome")

#create an empty dataframe for containing the results
contig_lengths<-data.frame(Contig_name=character(0),Contig_length=integer(0))

#extract the name of the contig and the length
fasta_parsed<-readDNAStringSet(filepath = input_path,format='fasta' )
Contig_name<-as.character(names(fasta_parsed))
Contig_length<-as.integer(lengths(fasta_parsed))
tmp_df<-data.frame(Contig_name,Contig_length)
contig_lengths<-rbind(contig_lengths,tmp_df)

#Rename the contigs with separate
suppressMessages(contig_lengths<-separate(contig_lengths,'Contig_name',into=c('Contig_name','Excess_name'),sep=' ',remove=TRUE))
suppressMessages(contig_lengths <- contig_lengths[,-c(2)])

#combine with contig-lengths
gplas_output<-join(gplas_output,contig_lengths)

# create data_frame
strain_name <-as.character(gplas_output$Genome_id[1])
strain_name<-gsub("_raw_nodes$","",strain_name)
gplas_ordered<-gplas_output[,c(8,9,7,1)]
names(gplas_ordered)<-c('Prob_Chromosome','Prob_Plasmid','Prediction','Contig_name')
gplas_ordered<-join(gplas_ordered,contig_lengths)
output_path<-paste(output_directory,'/gplas_format/',strain_name,'_plasmid_prediction.tab',sep='')
write.table(gplas_ordered,output_path,row.names = FALSE, sep='\t')

