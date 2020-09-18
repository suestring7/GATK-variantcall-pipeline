#!/bin/bash
#$ -m beas
#$ -q bio,adl,sf,pub*,free* 
#$ -ckpt restart
#$ -l h_vmem=16g
#$ -l mem_free=20g

GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
module load java/1.8.0.111
module load samtools

sample=$1
sp=$2


#[ -f $sp-sorted/${sample}_sorted.bam ] || java -d64 -Xmx8g -jar $GATK SortSam \
samtools quickcheck -v $sp-sorted/${sample}_sorted.bam || java -d64 -Xmx8g -jar $GATK SortSam \
-I=$sp-raw/${sample}.bam \
-O=$sp-sorted/${sample}_sorted.bam \
--SORT_ORDER=coordinate \
--CREATE_INDEX=true


#MarkDuplicates before merge
#[ -f $sp-dedup/${sample}.dedup.bam ] || java -jar $GATK MarkDuplicates \
samtools quickcheck -v $sp-dedup/${sample}.dedup.bam || java -jar $GATK MarkDuplicates \
--TMP_DIR=tmp \
-I=$sp-sorted/${sample}_sorted.bam \
-O=$sp-dedup/${sample}.dedup.bam \
--METRICS_FILE=$sp-dedup/${sample}.dedup.metrics.txt \
--REMOVE_DUPLICATES=false \
--TAGGING_POLICY=All

[ -f $sp-val/${sample}.validate.txt ] || java -d64 -Xmx8g -jar $GATK ValidateSamFile \
-I=$sp-dedup/${sample}.dedup.bam \
-O=$sp-val/${sample}.validate.txt \
--MODE=SUMMARY
