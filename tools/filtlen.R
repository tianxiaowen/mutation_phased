arg<-commandArgs(TRUE)
triofile<-arg[[1]]
maxlen<-as.numeric(arg[[2]])
outfile<-arg[[3]]

gettrio<-function(x){
  trio7<-x*7
  trio1<-trio7-6
  trio1:trio7
}

trios<-read.table(triofile,fill=T,stringsAsFactors=F)
len<-nrow(trios)/7
include<-numeric(len)
for (k in 1:len){
  cut<-k*7
  seglen<-(trios[cut-6:4,5]-trios[cut-6:4,4])/1E6
  include[k]<-prod(seglen<=maxlen)
}
  keeptrio<-which(include==1)
  keeprow<-sapply(keeptrio,gettrio)
  finaltrios<-trios[keeprow,]
  write.table(finaltrios,outfile,quote=F,col.names=F,row.names=F,na="")
