#!/bin/bash
#$ -m beas
#$ -q bio,abio,abio128,adl,sf,pub*,free*
#$ -ckpt restart
#$ -pe openmp 2


# when it gets stable, the top results to be ~2 cores.

GATK="/data/users/ytao7/software/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar"
module load java/1.8.0.111

ref=$1
sp=$2
sampleFile=$3
postfix=$4
i=$6
list=$7
ni=$8
interval=$(head -n $ni $list | tail -n 1)

idir=$sp-gvcf
odir=$sp-db
tmp=""
while read prefix
do
    tmp="$tmp -V $idir/$prefix$postfix"
done < $sampleFile
echo $tmp

rm $odir/${sp}-$interval -r

java -d64 -Xmx32g -jar $GATK GenomicsDBImport \
-R $ref \
--genomicsdb-workspace-path $odir/${sp}-$interval \
--batch-size 100 \
--reader-threads $CORES \
--overwrite-existing-genomicsdb-workspace \
-L $interval \
$tmp
