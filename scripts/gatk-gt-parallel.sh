#!/bin/bash
#$ -m beas
#$ -q abio,bio,abio128,adl,sf
#$ -pe openmp 8
#$ -l h_vmem=16g
#$ -l mem_free=20g
#$ -ckpt restart

GATK="/data/users/ytao7/software/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar"
module load java/1.8.0.111

ref=$1
sp=$2
i=$3
chrFmt=$4
list=$5
ni=$6

idir=$sp-db
odir=$sp-vcf

interval=$(head -n $ni $list | tail -n 1)

echo `hostname`
chr=$chrFmt$i
tmp=TMP-$chr
[ -d $odir/$tmp ] || mkdir $odir/$tmp
len=$(grep $chr$'\t' $ref.fai | cut -f2)
#interval=$chr:$Istart-$Iend
echo $interval
[ -f $odir/$tmp/${sp}_${ni}.vcf.idx ] || java -d64 -Xmx64g -XX:ParallelGCThreads=1 -jar $GATK GenotypeGVCFs \
-R $ref \
-V gendb://$idir/${sp}-$interval \
-O $odir/$tmp/${sp}_${ni}.vcf \
--max-genotype-count 2 \
--use-new-qual-calculator \
--verbosity DEBUG \
--founder-id DC \
--founder-id CA \
-L $interval


