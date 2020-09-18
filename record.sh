#!/bin/bash
#$ -m beas
#$ -q abio128,abio,bio,adl,sf,free*,pub* 
#$ -ckpt restart

# path to the programs
GATK="/data/apps/gatk/4.0.4.0/gatk-package-4.0.4.0-local.jar"
module load java/1.8.0.111
module load samtools

# parameters about your data
data="/share/adl/ytao7/CHAPTER2_Cichlid_QTL/data"
ref="DC.fix.fasta"
REF="DCf"
sp="DCf"
chrNum=22

# the $names is a list of fastq files sorted by sample
# in the format:
# $fastqname1 \t $samplename1
# $fastqname2 \t $samplename1
# .......
names="names.sorted.txt"
# the list of samplenames
# in the format:
# $samplename1
# $samplename2
# ......
sampleFile="names.sample.txt"

# make directories for the future steps
[ -d $sp-raw ] || mkdir $sp-raw
[ -d $sp-sorted ] || mkdir $sp-sorted
[ -d $sp-dedup ] || mkdir $sp-dedup
[ -d $sp-val ] || mkdir $sp-val
[ -d $sp-merge ] || mkdir $sp-merge
[ -d $sp-gvcf ] || mkdir $sp-gvcf
[ -d $sp-db ] || mkdir $sp-db
[ -d $sp-vcf ] || mkdir $sp-vcf


# Index the reference fasta file
bash scripts/bwa-idx.sh $ref
[ -f ${ref/fasta/dict} ] || qsub -N genDict$REF scripts/genDict.sh $ref ${ref/fasta/dict}
# the first file of the files
last=$(head -n 1 $names |cut -f2)
while read -r line
do
   # the following lines are file naming processing, alter it to fit your names
   samplename=F${line#*F}
   filename=${line%F*}
   filename=$(echo $filename | xargs)
   sampledir=$data/${filename%-P*}
   # to check if your file format is ok
   #echo "bam/$filename-$samplename.bam"
   # samtools quickcheck can check if the bam file is complete quickly so that we can rerun the pipeline
   samtools quickcheck -v $sp-raw/$filename-$samplename.bam || qsub -N bwa$samplename scripts/bwa-mem.sh $samplename $filename $ref $sampledir $sp
   [ -f $sp-val/${filename}-${samplename}.validate.txt ] || qsub -N val$samplename -hold_jid bwa$samplename scripts/gatk-val.sh $filename-$samplename $sp
   # to prevent overload of the SGE system...
   while [ $(qstat -u $USER|grep merge|wc -l) -gt 100 ]
   do
   sleep 200
   done
   # if all the fq of one sample have been submitted, submit the merge step
   [ $samplename == $last ] || [ -f $sp-merge/$last.bam.bai ] || qsub -N merge$last -hold_jid bwa$last,val$last scripts/sam-merge.sh $last $sp
   last=$samplename
done < $names
# deal with the last merge sample
[ -f $sp-merge/$last.bam.bai ] || qsub -N merge$last -hold_jid bwa$last,val$last scripts/sam-merge.sh $last $sp

# After the above steps. we got the merged bam files
# Then get the gvcf
while read -r sample
do		
   for i in $(seq 1 $chrNum)
   do
   		# there are some setting for low coverage data, you might want to change it in the scripts
       [ -f $sp-gvcf/$sample.$i.raw.g.vcf.idx ] || qsub -N gvcf.$sample.$i -hold_jid val$sample,genDict$REF,merge$sample scripts/gatk-hc.sh $sample $ref $sp $chrFmt $i lc
   done
   # still, avoid overload
   while [ $(qstat -u ytao7 | grep "gvcf" | wc -l) -gt 100 ]
   do
   sleep 100
   done
done < $sampleFile

#calculate lists of chunks separated by N in ref
python scripts/DivideByN.py $ref 0
mkdir list
mv *.list list

# merge the small chunks to the chunk size that you want to parallel
chunksize=10000000

# run db and gt in parallel
for i in $(seq 1 $chrNum)
do
   python scripts/MergeN.py list/chr$i.list $chunksize
   list=list/chr$i-$chunksize.list
   #number of chunks
   n=$(wc -l $list | cut -d" " -f1)
	for ni in $(seq 1 $n)
	do
		if [[ -z $(grep -P pdb-$i"\t"$ni"\t" run-analysis/sum-pdb-run.txt) ]]
		then
	    	qsub -N pdb-$i.$ni -hold_jid gvcf.$i scripts/gatk-db-parallel.sh $ref $sp $sampleFile ".$i.raw.g.vcf" $chrFmt $i $list $ni
		fi
		# submit if not running or done
		if [[ -z $(qstat -u $USER | grep pgt-$i.$ni" ") ]]
		then
   	   	[ -f $sp-vcf/TMP-${chrFmt}$i/${sp}_$ni.vcf.idx ] || qsub -N pgt-$i.$ni -hold_jid pdb-$i.$ni scripts/gatk-gt-parallel.sh $ref $sp $i $chrFmt $list $ni
		fi
	done

# The file name format for vcf is fixed-written in gatk-gt, you might want to change it
done


# merge the paralleled runs
head TMP-${chrFmt}1/${sp}_1.vcf -n 1000 | grep "^#" > header.vcf
for chr in $(seq 1 $chrNum)
do
	qsub -N gtm-$chr-$REF scripts/gatk-gt-merge.sh $sp $chr $chrFmt
done

# filter the variants following some standard
for chr in $(seq 1 $chrNum)
do
vcf=$sp-$chr.vcfqsub -N filter-$chr-$REF -hold_jid gtm-$chr-$REF scripts/gatk-filter.sh $ref $sp-$chr.vcf $sp-vcf $sp-vcf 
# MAF
thrs=.3
qsub -hold_jid filter-$chr-$REF -N pos.$chr$thrs scripts/geno/pos.sh $sp-vcf/$sp-${chr}_pass.vcf $thrs $chr  
done
