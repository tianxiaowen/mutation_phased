i=1
path=simulation/sim${i}

## simulation
## sample size: 4000 haplotypes
## effective population size: constant haploid size 20000
## mutation rate: 1.3e-8 per basepair per generation
## recombination rate: 1e-8
## length: 100 Mb
## true IBD length: 1cM
java -jar ARGON/ARGON.0.1.jar -N 20000 -pop 1 4000 -size 100 -mut 1.3E-8 -seed $i -IBD 1.0 -out $path/set${i} -gz

## format vcf file
zcat $path/set${i}.vcf.gz|grep -v "^##"|head -1 >  $path/header
zcat $path/set${i}.vcf.gz|grep -v "^#"|awk -v OFS='\t' '{print $1,$2,$3,"A","C"}' > $path/firstcol
zcat $path/set${i}.vcf.gz|grep -v "^#"|cut -f6- > $path/lastcol
(cat $path/header;
paste -d "\t" $path/firstcol $path/lastcol|sort -k 2 -n)|python tools/adjustvcfpos.py > $path/set${i}.vcf
rm $path/firstcol $path/lastcol $path/header $path/set${i}.vcf.gz
gzip $path/set${i}.vcf

## add errors to the data
rate=0.0002
zcat $path/set${i}.vcf.gz|java -jar tools/adderr.jar $rate|gzip > $path/set${i}.vcf.error${rate}.gz
