#!/bin/bash
#$ -m beas
#$ -q bio,adl,sf,pub*,free* 

module load bwa/0.7.17-5g
bwa index $1
