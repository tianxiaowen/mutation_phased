# usage: cat vcffile | python adjustvcfpos.py > outvcf
# moves positions forward if positions are identical

import sys

oldpos = -10000000
for line in sys.stdin:
    if line[0]=="#":
        print line,
        continue
    bits = line.split("\t",2)
    pos = int(bits[1])
    if pos <= oldpos:
        pos = oldpos + 1
    print bits[0]+"\t"+str(pos)+"\t"+bits[2],
    oldpos = pos
