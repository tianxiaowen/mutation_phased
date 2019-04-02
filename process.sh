#!/bin/bash

i=1
path=simulation/sim${i}
rate=0.0002

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

## find trios
#Rscript tools/findibd3.R $i $path/set${i}_error${rate}_refinedmatch.merged.3cM.ibd $path/set${i}_error${rate}_trios.3cM.txt

## get mutation counts
## recode the genotype so 1 is the minor allele
## keep markers less than 250 copies
copy=250

#awk -v OFS="\t" '{print $0,"nochange"}' $path/set${i}.vcf.error${rate}.gtstats|awk -v OFS="\t" '{if ($11!=$13) $16="change";print $0}'| awk -v OFS="\t" -v copy=$copy '{if($13<=copy) print $0}' > $path/markers${copy}_error${rate}_minor
#cut -f2  $path/markers${copy}_error${rate}_minor > $path/filter${i}_${copy}
#zcat $path/set${i}.vcf.error${rate}.gz| java -jar tools/filterlines.jar 2 $path/filter${i}_${copy}|sed 's|\||\t|g' > $path/set${i}_${copy}gt_error${rate}

#python tools/changevcf.py $path/markers${copy}_error${rate}_minor $path/set${i}_${copy}gt_error${rate} 4000 > $path/set${i}_${copy}gt_error${rate}_recode
#rm $path/set${i}_${copy}gt_error${rate} $path/filter${i}_${copy} $path/markers${copy}_error${rate}_minor

#row=$(wc -l $path/set${i}_${copy}gt_error${rate}_recode|cut -d " " -f1)
#Rscript tools/loadvcf.R $path/set${i}_${copy}gt_error${rate}_recode $row
#rm $path/set${i}_${copy}gt_error${rate}_recode

#Rscript tools/findibd3gt.R $path/set${i}_${copy}gt_error${rate}_recode.Rdata $path/set${i}_error${rate}_trios.3cM.txt $path/set${i}_error${rate}_trios_${copy}gt.3cM.txt

## remove ibd segments longer than 6cM
#Rscript tools/filtlen.R $path/set${i}_error${rate}_trios_${copy}gt.3cM.txt 6 $path/set${i}_error${rate}_trios_${copy}gt.3-6cM.txt

## get mutation rate estimtate
## effective populaion size can be estimated using IBDNe
cat $path/set${i}_error${rate}_trios_${copy}gt.3-6cM.txt | java -jar tools/mutation.09Mar17.304.jar ng1=300 ng2=300 mu.start=1.28E-8 mu.end=1.35E-8 mu.step=1E-10 err.start=5E-10 err.end=1.25E-8 err.ratio=1.25 map=constant.map ne=simulation/sim.ne nthreads=12 out=$path/set${i}_error${rate}.3-6cM
