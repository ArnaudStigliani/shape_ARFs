args = commandArgs(trailingOnly=TRUE)
matrix <- args[1]

pfm <- read.table(matrix,header=TRUE, skip=1, sep="\t")

jaspar_pfm <- t(pfm)

write.table(jaspar_pfm, file=paste(matrix,".brut",sep=""),quote=FALSE,sep=" ",col.names=FALSE)
