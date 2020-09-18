#!/bin/bash
#$ -m beas
#$ -q bio,abio,abio128,adl,sf,pub*,free* 
#$ -ckpt restart
#$ -pe openmp 8


# when it gets stable, the top results to be ~2 cores.

GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
module load java/1.8.0.111

ref=$1
sp=$2
sampleFile=$3
postfix=$4
i=$6
interval=$5$i
idir=$sp-gvcf
odir=$sp-db
tmp=""
while read prefix
do
    tmp="$tmp -V $idir/$prefix$postfix"
done < $sampleFile
echo $tmp
java -d64 -Xmx32g -jar $GATK GenomicsDBImport \
-R $ref \
--genomicsdb-workspace-path $odir/${sp}_$i \
--batch-size 100 \
--reader-threads $CORES \
--overwrite-existing-genomicsdb-workspace \
-L $interval \
$tmp

##--consolidate \
#
##java -d64 -Xmx32g -jar $GATK GenomicsDBImport \
##-R $ref \ # the reference
##--genomicsdb-workspace-path $odir/${REF}_$i \ # the place to put the result
##--batch-size 100 \ # to read certain amount of files at once, prevent OutOfMemory error
##--consolidate \ # their document claim this argument can speed it up when you use large batch-size 
##--reader-threads $CORES \ # to speed up
##--overwrite-existing-genomicsdb-workspace \ # in case it restarts the job
##-L $interval \ # they only allowed interval / but they add the feature of calling multiple intervals at once
##$tmp
