library(pROC)
library(Cairo)
args = commandArgs(trailingOnly=TRUE)
#args <- c("../results/files/tab_scores_ARF2_ER7.tsv","../results/files/tab_scores_ARF2_ER8.tsv")


arrayName <- c(args[1],args[2])

ARF2_ER7 <- read.table(arrayName[1],sep="\t")
rocARF2_ER7 <- roc(cases=ARF2_ER7[,1],controls=ARF2_ER7[,2])

ARF2_ER8 <- read.table(arrayName[2],sep="\t")
rocARF2_ER8 <- roc(cases=ARF2_ER8[,1],controls=ARF2_ER8[,2])


Cairo(file=paste("../results/files/ROC_",Sys.Date(),".png",sep=""),type="png",width=600,height=600,bg='white')
par(xaxs="i",yaxs="i")
plot(rocARF2_ER7,col="orange",identity=FALSE,xlab="Unbound sequences",ylab="Bound sequences")
lines(rocARF2_ER8,col="cornflowerblue",legacy.axes=TRUE)
legend(x=0.4,y=0.2,legend=c(paste("ARF2_ER7",as.character(round(rocARF2_ER7$auc,2)),sep=" = "),paste("ARF2_ER8",as.character(round(rocARF2_ER8$auc,2)),sep=" = ")),bty="n",text.col=c("orange","cornflowerblue"),cex=1.3)
dev.off()

