i=1
path=simulation/sim${i}
rate=0.0002
#Rscript tools/findtrios.R $i $path/set${i}_error${rate}_refinedmatch.merged.3cM.ibd $path/set${i}_error${rate}_trios.3cM.txt

Rscript tools/findtrios.end.R $i $path/set${i}_error${rate}_refinedmatch.merged.3cM.ibd $path/set${i}_error${rate}_trios_end.3cM.txt
