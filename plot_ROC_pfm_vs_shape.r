library(pROC)
library(Cairo)
args = commandArgs(trailingOnly=TRUE)
#args <- c("../results/files/tab_scores_ARF2_pfm.tsv","../results/files/tab_scores_ARF2_shape.tsv")
namePlot <- args[3]
output <- args[4]
TF <- args[5]

arrayName <- c(args[1],args[2])

ARF2_pfm <- read.table(arrayName[1],sep="\t")
rocARF2_pfm <- roc(cases=ARF2_pfm[,1],controls=ARF2_pfm[,2])

ARF2_shape <- read.table(arrayName[2],sep="\t")
rocARF2_shape <- roc(cases=ARF2_shape[,1],controls=ARF2_shape[,2])


Cairo(file=paste(output,"/ROC_",Sys.Date(),"_",namePlot,"_",".png",sep=""),type="png",width=600,height=600,bg='white')
par(xaxs="i",yaxs="i")
plot(rocARF2_pfm,col="orange",identity=FALSE,xlab="Unbound sequences",ylab="Bound sequences")
#lines(rocARF2_shape,col="cornflowerblue",legacy.axes=TRUE)
legend(x=0.4,y=0.2,legend=c(paste(TF," pfm = ",as.character(round(rocARF2_pfm$auc,2)),sep=""),paste(TF," shape = ",as.character(round(rocARF2_shape$auc,2)),sep="")),bty="n",text.col=c("orange","cornflowerblue"),cex=1.3)
dev.off()

