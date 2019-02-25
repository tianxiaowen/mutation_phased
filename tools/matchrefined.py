## get merged ibd where bounds having same phase
## usage: python matchrefined.py bound merged triolen 

import sys
import pandas as pd
import numpy as np

refinedname = sys.argv[1]
mergename = sys.argv[2]
overlen = sys.argv[3]

refined = pd.read_csv(refinedname,compression='gzip',header=None, sep="\t")
merged = open(str(mergename))

refined = refined.drop_duplicates()

for line in merged:
  bits = line.split()
  if float(bits[8]) >= float(overlen):
    hapid1 = bits[1]
    hapid2 = bits[3]
    if hapid1 != '0' and hapid2 != '0':
      bits[0] = bits[0].split("_")[1]
      bits[2] = bits[2].split("_")[1]
      print '\t'.join(bits) 
      continue
    else:
      id1 = bits[0]
      id2 = bits[2]
      start = int(bits[5])
      end = int(bits[6])
      idmatch = refined[((refined[0]==id1)&(refined[2]==id2))|((refined[0]==id2)&(refined[2]==id1))]
      if len(idmatch)>0:
        matchlen = []
        for i in range(0,len(idmatch)):
          matchlen.append(min(idmatch.iloc[i,6],end)-max(idmatch.iloc[i,5],start))
        matchlen = np.array(matchlen)
        if (matchlen>0).sum()>0:
          lenmatch = idmatch[matchlen>0]
          allmatch = lenmatch.iloc[:,2:4]
          allmatchid = pd.concat([allmatch.rename({2:0,3:1},axis='columns'), lenmatch.iloc[:,0:2]])
          uniqueid = allmatchid.drop_duplicates()         
          if len(uniqueid)==2:
            bits[bits.index(uniqueid.iloc[0,0])+1] = uniqueid.iloc[0,1]
            bits[bits.index(uniqueid.iloc[1,0])+1] = uniqueid.iloc[1,1]
            bits[1] = str(bits[1])
            bits[3] = str(bits[3])
            bits[0] = bits[0].split("_")[1]
            bits[2] = bits[2].split("_")[1]
            print '\t'.join(bits) 

