#!/bin/bash
#$ -m beas
#$ -q bio,abio,adl,sf,pub*,free* 
#$ -pe openmp 8
#$ -ckpt restart
#$ -R y

module load bwa/0.7.17-5g
module load samtools

samplename=$1
prefix=$2-
ref=$3
idir=$4
sp=$5

info=$(zcat $idir/${prefix}READ1-Sequences.txt.gz | head -n 1)
barcode=$(echo $info | cut -d':' -f3)
lane=$(echo $info | cut -d':' -f4)
library="unknown"
[ -f $idir/${prefix}SampleBasicInfo.txt ] && library=$(head -n 2 $idir/${prefix}SampleBasicInfo.txt | tail -n 1 | cut -d' ' -f3)

bwa mem -t $CORES -R '@RG\tID:'$samplename'\tPU:'$barcode.$lane.$samplename'\tSM:'$samplename'\tPL:illumina\tLB:'$library -M $ref $idir/${prefix}READ1-Sequences.txt.gz $idir/${prefix}READ2-Sequences.txt.gz | samtools view -bS - > $sp-raw/${prefix}$samplename.bam 
