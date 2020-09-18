#!/bin/bash
#$ -m beas
#$ -q bio,abio,abio128,adl,sf,pub*,free* 
#$ -ckpt restart

GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
module load java/1.8.0.111

ref=$1
REF=$2
sampleFile=$3
postfix=$4
i=$6
interval=$5$i
idir=$7
odir=$8
tmp=""
while read prefix
do
    tmp="$tmp -V $idir/$prefix$postfix"
done < $sampleFile

java -d64 -Xmx32g -jar $GATK CombineGVCFs \
-R $ref \
-O $odir/${REF}_$i \
$tmp
