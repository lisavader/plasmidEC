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
combined <- full_join(full_join(mlplasmids,platon),full_join(rfplasmid,plascope))
combined <- combined[, colSums(is.na(combined)) != nrow(combined)] #remove column of non-included tool

