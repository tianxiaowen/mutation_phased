#!/bin/bash

i=1
path=simulation/sim${i}

## simulation
## sample size: 4000 haplotypes
## effective population size: constant haploid size 20000
## mutation rate: 1.3e-8 per basepair per generation
## recombination rate: 1e-8
## length: 100 Mb
## true IBD length: 1cM
#java -jar ARGON/ARGON.0.1.jar -N 20000 -pop 1 4000 -size 100 -mut 1.3E-8 -seed $i -IBD 1.0 -out $path/set${i} -gz

## format vcf file
#zcat $path/set${i}.vcf.gz|grep -v "^##"|head -1 >  $path/header
#zcat $path/set${i}.vcf.gz|grep -v "^#"|awk -v OFS='\t' '{print $1,$2,$3,"A","C"}' > $path/firstcol
#zcat $path/set${i}.vcf.gz|grep -v "^#"|cut -f6- > $path/lastcol
#(cat $path/header;
#paste -d "\t" $path/firstcol $path/lastcol|sort -k 2 -n)|python tools/adjustvcfpos.py > $path/set${i}.vcf
#rm $path/firstcol $path/lastcol $path/header $path/set${i}.vcf.gz
#gzip $path/set${i}.vcf

## add errors to the data
rate=0.0002
#zcat $path/set${i}.vcf.gz|java -jar tools/adderr.jar $rate|gzip > $path/set${i}.vcf.error${rate}.gz

## get summary statistics from vcf file
#zcat $path/set${i}.vcf.error${rate}.gz | java -jar tools/gtstats.jar > $path/set${i}.vcf.error${rate}.gtstats

## exclude MAF<10% for IBD detection
#awk -v OFS=":" '{if($14<0.1) print $1,$2}' $path/set${i}.vcf.error${rate}.gtstats > $path/exclude_markers_error${rate}

## Refined IBD using true phase
#java -Xmx120g -Xss5m -jar tools/refined-ibd.12Jul18.a0b.jar gt=$path/set${i}.vcf.error${rate}.gz  excludemarkers=$path/exclude_markers_error${rate} map=constant.map length=1 nthreads=12 out=$path/set${i}_error${rate}_refined

## gap filling
#zcat $path/set${i}_error${rate}_refined.ibd.gz | java -jar tools/merge-ibd-segments.12Jul18.a0b.jar $path/set${i}.vcf.error${rate}.gz constant.map 0.5 2 > $path/set${i}_error${rate}_refined.merged.ibd

## match merged IBD, change id
#export PATH=/projects/browning/brwnlab/tian/python/anaconda2/bin:$PATH
#python tools/matchrefined.py $path/set${i}_error${rate}_refined.ibd.gz $path/set${i}_error${rate}_refined.merged.ibd 3 > $path/set${i}_error${rate}_refinedmatch.merged.3cM.ibd

## estimate effective population size
#cat $path/set${i}_error${rate}_refined.merged.ibd | java -jar tools/ibdne.07May18.6a4.jar map=constant.map out=$path/set${i}_error${rate}_refined.merged nboots=0

## find trios
#Rscript tools/findtrios.R $i $path/set${i}_error${rate}_refinedmatch.merged.3cM.ibd $path/set${i}_error${rate}_trios.3cM.txt

## get mutation counts
## change 01 if minor allele is reference allele
## keep markers less than 750 copies
#copy=750

#awk -v OFS="\t" '{print $0,"nochange"}' $path/set${i}.vcf.error${rate}.gtstats|awk -v OFS="\t" '{if ($11!=$13) $16="change";print $0}'| awk -v OFS="\t" -v copy=$copy '{if($13<=copy) print $0}' > $path/markers${copy}_error${rate}_minor
#cut -f2  $path/markers${copy}_error${rate}_minor > $path/filter${i}_${copy}
#zcat $path/set${i}.vcf.error${rate}.gz| java -jar tools/filterlines.jar 2 $path/filter${i}_${copy}|sed 's|\||\t|g' > $path/set${i}_${copy}gt_error${rate}

#python tools/changevcf.py $path/markers${copy}_error${rate}_minor $path/set${i}_${copy}gt_error${rate} 4000 > $path/set${i}_${copy}gt_error${rate}_changed
#rm $path/set${i}_${copy}gt_error${rate} $path/filter${i}_${copy} $path/markers${copy}_error${rate}_minor

#row=$(wc -l $path/set${i}_${copy}gt_error${rate}_changed|cut -d " " -f1)
#Rscript tools/loadvcf.R $path/set${i}_${copy}gt_error${rate}_changed $row
#rm $path/set${i}_${copy}gt_error${rate}_changed

#Rscript tools/findtriosgt.R $path/set${i}_${copy}gt_error${rate}_changed.Rdata $path/set${i}_error${rate}_trios.3cM.txt $path/set${i}_error${rate}_trios_${copy}gt.3cM.txt

#Rscript filtlen.R $path/set${i}_error${rate}_trios_${copy}gt.3cM.txt 6 $path/set${i}_error${rate}_trios_${copy}gt.3-6cM.txt

## get mutation rate estimtate
cat $path/set${i}_error${rate}_trios_${copy}gt.3-6cM.txt | java -jar mutation.09Mar17.304.jar ng1=300 ng2=300 mu.start=1.25E-8 mu.end=1.35E-8 mu.step=1E-10 err.start=1E-10 err.end=1E-8 err.rate=5 map=constant.map ne=$path/set${i}_error${rate}_refined.merged.ne nthreads=12 out=$path/set${i}_error${rate}.3-6cM
