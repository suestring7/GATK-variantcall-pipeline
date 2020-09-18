#!/bin/bash
#$ -m beas
#$ -q abio,abio128,bio,adl,sf,krt,krti,pub*,free*
#$ -pe openmp 2
#$ -l h_vmem=16g
#$ -l mem_free=20g
#$ -ckpt restart

GATK="/data/users/ytao7/software/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar"
module load java/1.8.0.111

ref=$1
REF=$2
i=$3
chrFmt=$4
idir=$5
odir=$6
Istart=$7

chr=$chrFmt$i
tmp=TMP-$chr
[ -d $odir/$tmp ] || mkdir $odir/$tmp

len=$(grep $chr$'\t' $ref.fai | cut -f2)
interval=$chr:$Istart-$len

[ -f $odir/$tmp/${REF}_$interval.vcf.idx ] || java -d64 -Xmx8g -XX:ParallelGCThreads=1 -jar $GATK GenotypeGVCFs \
-R $ref \
-V gendb://$idir/${REF}_$i \
-O $odir/$tmp/${REF}_$Istart.vcf \
--founder-id DC_founder \
--founder-id CA_founder \
--max-genotype-count 4 \
-L $interval

