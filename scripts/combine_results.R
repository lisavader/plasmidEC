##Load results
all_results <- read.csv("../results/all_results.csv", header = FALSE)
names(all_results) <- c("contig_name","prediction","software")

##Process each software
mlplasmids <- all_results[all_results$software=='mlplasmids',]
mlplasmids <- mlplasmids[,c(1,2)]
names(mlplasmids) <- c("contig_name","mlplasmids")

platon <- all_results[all_results$software=='platon',]
platon <- platon[,c(1,2)]
names(platon) <- c("contig_name","platon")

plascope <- all_results[all_results$software=='plascope',]
plascope <- plascope[,c(1,2)]
names(plascope) <- c("contig_name","plascope")

rfplasmid <- all_results[all_results$software=='rfplasmid',]
rfplasmid <- rfplasmid[,c(1,2)]
names(rfplasmid) <- c("contig_name","rfplasmid")

##Combine results
combined <- merge(merge(mlplasmids,platon,all = TRUE),merge(rfplasmid,plascope, all = TRUE),all = TRUE)
combined <- combined[, colSums(is.na(combined)) != nrow(combined)] #remove column of non-included tool
combined$plasmid_count <- apply(combined, 1, function(x) length(which(x=="plasmid")))

##Assign plasmid if called by more than one of the tools
combined$classification <- "chromosome"
combined$classification[combined$plasmid_count>1] <- "plasmid"

##Write output file
write.csv(combined,"../final_output.csv",row.names = FALSE)
