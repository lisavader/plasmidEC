
##get the input and output dir from command line arguments.
arguments = commandArgs(trailingOnly=TRUE)
output_directory=arguments[1]

##Load results
all_results_path<-paste("../",output_directory,"/all_predictions.csv",sep='')
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


