#!/bin/bash
#$ -m beas
#$ -q bio,abio,abio128,adl,sf,pub*,free* 
#$ -ckpt restart
#$ -pe openmp 2
#$ -l h_vmem=10g
#$ -l mem_free=10g


module load java/1.8.0.111
GATK="/data/users/ytao7/software/gatk-4.1.0.0/gatk-package-4.1.0.0-local.jar"

ref=$1
vcf=$2
idir=$3
odir=$4

#java -d64 -Xmx8g -jar $GATK SelectVariants \
#-R $ref \
#-V $idir/$vcf \
#--select-type INDEL \
#-O $odir/${vcf/.vcf/_indel.vcf}

java -d64 -Xmx8g -jar $GATK SelectVariants \
-R $ref \
-V $idir/$vcf \
--select-type SNP \
-O $odir/${vcf/.vcf/_snp.vcf}

java -d64 -Xmx8g -jar $GATK VariantFiltration \
-R $ref \
-V $odir/${vcf/.vcf/_snp.vcf} \
--filter-expression "QD < 5.0" \
--filter-name "LowVQCBD" \
--filter-expression "(vc.isSNP() && (vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -8.0)) || ((vc.isIndel() || vc.isMixed()) && (vc.hasAttribute('ReadPosRankSum') && ReadPosRankSum < -20.0)) || (vc.hasAttribute('QD') && QD < 2.0) " \
--filter-name "badSeq" \
--filter-expression "(vc.isSNP() && ((vc.hasAttribute('FS') && FS > 60.0) || (vc.hasAttribute('SOR') &&  SOR > 3.0))) || ((vc.isIndel() || vc.isMixed()) && ((vc.hasAttribute('FS') && FS > 200.0) || (vc.hasAttribute('SOR') &&  SOR > 10.0)))" \
--filter-name "badStrand" \
--filter-expression "vc.isSNP() && ((vc.hasAttribute('MQ') && MQ < 40.0) || (vc.hasAttribute('MQRankSum') && MQRankSum < -12.5))" \
--filter-name "badMap" \
-O $odir/${vcf/.vcf/_filtered.vcf}
--filter-expression "!vc.hasAttribute('DP')" \
--filter-name "noCoverage" \
--filter-expression "vc.hasAttribute('DP') && DP < MINDEPTH" \
--filter-name "MinCov" \
--filter-expression "vc.hasAttribute('DP') && DP > MAXDEPTH" \
--filter-name "MaxCov" \

java -d64 -jar $GATK SelectVariants \
-R $ref \
-V $odir/${vcf/.vcf/_filtered.vcf} \
--exclude-filtered true \
-O $odir/${vcf/.vcf/_pass.vcf}

