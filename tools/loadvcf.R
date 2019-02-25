arg <- commandArgs(TRUE)
gtname <- arg[[1]]
nr <- as.numeric(arg[[2]])
vcf<-read.table(gtname,nrows=nr)
save.image(paste(gtname,".Rdata",sep=""))
