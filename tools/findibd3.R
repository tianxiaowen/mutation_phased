arg <- commandArgs(TRUE)
chr <- as.numeric(arg[[1]])
ibdname <- arg[[2]]
outname <- arg[[3]]
options(scipen=999)
region<-100
ibd<-read.table(ibdname,stringsAsFactor=F)
newibd<-ibd
newibd$V1<-ibd$V1*2+ibd$V2-2 ##hapid
newibd$V2<-ibd$V3*2+ibd$V4-2 ##hapid
newibd$V3<-ibd$V6 ##start
newibd$V4<-ibd$V7 ##end
newibd$V5<-ibd$V9 ##length
newibd$V6<-ibd$V1 ##id
newibd$V7<-ibd$V3 ##id
newibd$V8<-chr
ibd<-newibd[,1:8]
trioid<-1
out<-list()

while (nrow(ibd)>=3) {
  line1<-head(ibd,1)
  id1<-line1[,1]
  id2<-line1[,2]
  ##for id1 match
  forid1<-ibd[(ibd$V1==id1 & ibd$V2!=id2)|(ibd$V2==id1 & ibd$V1!=id2),]
  ##for id2 match
  forid2<-ibd[(ibd$V1==id2 & ibd$V2!=id1)|(ibd$V2==id2 & ibd$V1!=id1),]
  same<-intersect(c(forid1[,1],forid1[,2]),c(forid2[,1],forid2[,2]))
  ##if nothing matches id1/id2, remove and continue
  if (length(same)>0){
    for (i in 1:length(same)){
      index1<-which(forid1[,1:2]==same[i],arr.ind=TRUE)
      index2<-which(forid2[,1:2]==same[i],arr.ind=TRUE)
      for (r1 in 1:nrow(index1)){
        for (r2 in 1:nrow(index2)){
          trio<-rbind(line1,forid1[index1[r1,1],],forid2[index2[r2,1],])
          idlen<-length(unique(c(trio[,6],trio[,7])))
          haplen<-length(unique(c(trio[,1],trio[,2])))
          seg1<-trio[1,4]-trio[1,3]
          seg2<-trio[2,4]-trio[2,3]
          seg3<-trio[3,4]-trio[3,3]
          minlen<-min(c(seg1,seg2,seg3))
          minlenid<-which(c(seg1,seg2,seg3)==minlen)[1]
          start_cover<-trio[minlenid,]$V3
          end_cover<-trio[minlenid,]$V4
          start<-trio[-minlenid,]$V3
          end<-trio[-minlenid,]$V4
          overlap_length<-min(end)-max(start)
          consistent_length<-end_cover-start_cover
          final<-sort(unique(c(start_cover,end_cover,start,end)))

          #remove segments reach either end of the chromosome region
          ##remove trios have same start/end positions
          ##if two overlap cover the thrid segment
          ##three unique ids from 3 different individuals
          ##(so use original individual id, not hapid)
          ##consistent length=overlap length
          if (prod(trio$V3>=9999&trio$V4<=(region-0.01)*10^6)*
              (length(unique(trio$V4))>1&length(unique(trio$V3))>1)*
              prod(start<=start_cover&end>=end_cover)*
              (length(final)==4)*(consistent_length==overlap_length)*
              (idlen==3)*(haplen==3)==1) {
            ##sort by starting position, 3rd line for covered segment
            useseg<-trio[-minlenid,]
            trio3ibd<-rbind(useseg[order(useseg$V3),],trio[minlenid,])
            trio3ibd<-trio3ibd[,c(1,2,8,3,4,5)]
            newtrio<-rbind(trio3ibd,c(final,0,NA))
            out[[trioid]]<-newtrio
            trioid<-trioid+1
          }
        }
      }
    }
  }
  ibd<-ibd[-1,]
}
options(scipen=999)
lapply(out,function(x) write.table(data.frame(x),file=outname,col.names=F,row.names=F,quote=F,na="",append=T))
