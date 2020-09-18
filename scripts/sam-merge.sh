#!/bin/bash
#$ -m beas
#$ -q bio,abio,adl,sf,pub*,free* 
#$ -ckpt restart
#$ -pe openmp 4
module load samtools

samplename=$1
sp=$2
cd $sp-dedup

echo $(ls *-$samplename.dedup.bam | wc -l)
[ -f ../$sp-merge/$samplename.bam ] && [ ! -f ../$sp-merge/$samplename.bam.bai ] && samtools index ../$sp-merge/$samplename.bam
[ -f ../$sp-merge/$samplename.bam.bai ] && exit 0
([ $(ls *-$samplename.dedup.bam | wc -l) -eq 1 ] && cp *-$samplename.dedup.bam ../$sp-merge/$samplename.bam ) || (samtools merge -@$CORES ${samplename}.tmp.bam *-$samplename.dedup.bam && mv ${samplename}.tmp.bam ../$sp-merge/$samplename.bam)
samtools index ../$sp-merge/$samplename.bam
