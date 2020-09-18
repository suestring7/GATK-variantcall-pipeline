#!/bin/bash
#$ -m beas
#$ -pe openmp 8
#$ -q bio,abio,abio128,adl,sf,pub*,free* 
#$ -ckpt blcr
##$ -l mem_size=30G

GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
module load java/1.8.0.111

ref=$1
dict=$2

java -jar $GATK CreateSequenceDictionary -R=$ref -O=$dict

