###Mutation rate estimation from three-way IBD

######Program: mutation.09Mar17.304.jar
######Copyright (C) 2016 Brian L. Browning

usage: cat [ibd] | java -jar mutation.09Mar17.304.jar [args]

where:
  [ibd]  = a space-separated list of trio-mutation files with the format specified below <br/>  [args] = a space-separated list of algorithm parameters

Algorithm Parameters:
  map=\<PLINK-format genetic map with cM distances> 	   		 (required)
  ne=<IBDNe .ne output file>                       						 (required)
  out=\<output file prefix>                        							 (required)
  ng1=\<max generations to first coalescence>        		 		 (default=100)
  ng2=\<max generations from 1st to 2nd coalescence> 			 (default=100)
  mu.start=\<min mutation rate>                     					 	 (default=1.21E-8)
  mu.end=\<max mutation rate>                       					 	 (default=1.29E-8)
  mu.step=\<step for grid search>                  				 		 (default=1.0E-10)
  err.start=\<min error rate>                        					 	 (default=0.0)
  err.end=\<max error rate>                          					 	 (default=1.0E-7)
  err.ratio=\<ratio >1 for logorithmic grid search>  				 	 (default=10.0)
  nthreads=\<number of threads>                     					 	 (default: machine-dependent)



[ibd]  = a space-separated list of trio-mutation files with the following format

​	[hapidA] [hapidB] [chr] [startAB] [endAB] [lengthAB] <br/>	[hapidA] [hapidC] [chr] [startAC] [endAC] [lengthAC] <br/>	[hapidB] [hapidC] [chr] [startBC] [endBC] [lengthBC] <br/>	12-3 	[mut12-3]	[overlap] <br/>	13-2	[mut13-2]	[overlap] <br/>	23-1	[mut23-1]	[overlap] <br/>

​	where:

​		[hapidA/B/C] = haplotype index <br/>		[chr] = chromosome index <br/>		[startAB/AC/BC] = starting physical position of the IBD segment shared between AB/AC/BC<br/>		[endAB/AC/BC] = ending physical position of the IBD segment shared between AB/AC/BC<br/>		[lengthAB/AC/BC] = genetic length of the IBD segment shared between AB/AC/BC<br/>		[mut12-3] = first sort hapidA, hapidB, hapidC by their numeric value into ascending order<br/>				      hapid1, hapid2, hapid3. Then mut12-3 is the number of variants carried <br/>				      exclusively  by hapid1 and hapid2 <br/>		[mut13-2] = number of variants carried exclusively  by hapid1 and hapid3 <br/>		[mut23-1] = number of variants carried exclusively  by hapid2 and hapid3 <br/>		[overlap] = the physical length of the overlapping region of three IBD segments
