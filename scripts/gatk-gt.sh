#!/bin/bash
#$ -m beas
#$ -q bio,abio,abio128,adl,sf 
#$ -ckpt restart
#$ -pe openmp 2
#$ -l h_vmem=10G



GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
GATK="/data/users/ytao7/software/gatk-4.0.12.0/gatk-package-4.0.12.0-local.jar"
module load java/1.8.0.111

ref=$1
sp=$2
i=$3
#interval=$5$i
idir=$sp-db
odir=$sp-vcf

mkdir $odir/tmp_$i
java -d64 -Xmx8g -jar $GATK GenotypeGVCFs \
-R $ref \
-V gendb://$idir/${sp}_$i \
-O $odir/${sp}_$i.vcf \
--tmp-dir=$odir/tmp_$i

##--heterozygosity 0.005 #what should be here for cichlid?
##-L $interval \
##-O $odir/${REF}_$i.vcf.gz 

rm -r $odir/tmp_$i
