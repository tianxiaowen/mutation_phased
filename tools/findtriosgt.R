arg<-commandArgs(TRUE)
gtfile<-arg[[1]]
triofile<-arg[[2]]
outfile<-arg[[3]]
load(gtfile)
options(scipen=999)
trios<-read.table(triofile,fill=T,stringsAsFactors=F)
triolen<-nrow(trios)/4
out<-list()
for (i in 1:triolen){
  cut<-i*4
  trio<-trios[cut-3:0,]
  ids<-sort(unique(c(trio[1:3,1],trio[1:3,2])))
  ## haplotype id starts from 1
  cols<-ids+9
  start<-trio[4,2]+500000
  end<-trio[4,3]-500000
  newover<-end-start
  gt<-vcf[vcf$V2>=start&vcf$V2<=end,cols]
  one<-sum((gt[,1]==1)*(gt[,2]==1)*(gt[,3]==0))
  two<-sum((gt[,1]==1)*(gt[,3]==1)*(gt[,2]==0))
  three<-sum((gt[,2]==1)*(gt[,3]==1)*(gt[,1]==0))
  out[[2*i-1]]<-trio
  out[[2*i]]<-data.frame(rbind(c("12-3",one,newover),c("13-2",two,newover),c("23-1",three,newover)))
}
options(scipen=999)
lapply(out,function(x) write.table(data.frame(x),file=outfile,col.names=F,row.names=F,quote=F,na="",append=T))
