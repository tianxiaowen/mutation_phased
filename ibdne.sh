#!/bin/bash
## Effective population size estimation
## In this example, Ne is estimated from 1 chromosome only
(for i in 1
do
cat simulation/sim${i}/set${i}_error0.0002_refined.merged.ibd
done)|java -jar tools/ibdne.07May18.6a4.jar map=constant.map out=simulation/sim nthreads=12 filtersamples=false mincm=2 nboots=0
