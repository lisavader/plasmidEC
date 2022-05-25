suppressMessages(library(tidyr))
##get the input and output dir from command line arguments.
arguments = commandArgs(trailingOnly=TRUE)
output_directory=arguments[1]

##Load results
all_results_path<-paste(output_directory,"/all_predictions.csv",sep='')
all_results <- read.csv(all_results_path, header = FALSE)
names(all_results) <- c("Contig_name","prediction","software","genome_id")

##Process each software
mlplasmids <- all_results[all_results$software=='mlplasmids',]
mlplasmids <- mlplasmids[,-c(3)]
names(mlplasmids) <- c("True_name","mlplasmids","Genome_id")
#separate the rfplasmid	name, in case there are spaces (which are not handled by plascope and platon)
mlplasmids<-suppressWarnings(separate(mlplasmids,'True_name',into=c('Contig_name','Excess_name'),sep=' ',remove=TRUE))
mlplasmids <- mlplasmids[,-c(2)]

platon <- all_results[all_results$software=='platon',]
platon <- platon[,-c(3)]
names(platon) <- c("Contig_name","Platon","Genome_id")

plascope <- all_results[all_results$software=='plascope',]
plascope <- plascope[,-c(3)]
names(plascope) <- c("Contig_name","PlaScope","Genome_id")

rfplasmid <- all_results[all_results$software=='rfplasmid',]
rfplasmid <- rfplasmid[,-c(3)]
names(rfplasmid) <- c("True_name","RFPlasmid","Genome_id")
#separate the rfplasmid	name, in case there are spaces (which are not handled by plascope and platon)
rfplasmid<-suppressWarnings(separate(rfplasmid,'True_name',into=c('Contig_name','Excess_name'),sep=' ',remove=TRUE))
rfplasmid <- rfplasmid[,-c(2)]

##Combine results
combined <- merge(merge(mlplasmids,rfplasmid,all = TRUE),merge(plascope,platon, all = TRUE),all = TRUE)
combined <- combined[, colSums(is.na(combined)) != nrow(combined)] #remove column of non-included tool
#replace NA of mlplasmids with 'chromosome'.if the column exists
if("mlplasmids" %in% colnames(combined)) {
 combined$mlplasmids<-ifelse(is.na(combined$mlplasmids),'chromosome',as.character(combined$mlplasmids));
}

#check if the number of rows is the same before and after the merge.
nrows_rfplasmid<-nrow(rfplasmid)
nrows_combined<-nrow(combined)
ncol_combined<-ncol(combined)
if((nrows_rfplasmid == nrows_combined) && ncol_combined==5){
print("Combination of tools outputs is OK")
} else {
print("Error during combination of tools output. Maybe you didn't select 3 different tools for classification?")
}   

##Assign plasmid if called by more than one of the tools
combined$Plasmid_count <- apply(combined, 1, function(x) length(which(x=="plasmid")))
combined$Combined_prediction <- "chromosome"
combined$Combined_prediction[combined$Plasmid_count>1] <- "plasmid"

##Write output file
combined_path<-paste(output_directory,'/ensemble_output.csv',sep='')
write.csv(combined,combined_path,row.names = FALSE)


