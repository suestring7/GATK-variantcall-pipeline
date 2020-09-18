#!/bin/bash
#$ -N gt-merge 
#$ -m beas
#$ -q bio,abio,abio128,adl,sf,pub*,free* 
#$ -ckpt restart 

sp=$1
chr=$2
chrFmt=$3
cd $sp-vcf
head -n 1000 TMP-${chrFmt}$chr/${sp}_1.vcf | grep "^#" > $sp-$chr.vcf

for file in $(ls TMP-${chrFmt}$chr/*.vcf | sort -k 1,1V)
do
       cat $file | grep -v "^#" >> $sp-$chr.vcf
done
