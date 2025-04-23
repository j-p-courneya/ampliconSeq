#!/bin/bash

# parameters
fastqList=$1
runName=$2
nbThread=2

# load modules

module load cutadapt
module load bwa
module load samtools
module load bedtools
module load java/1.8.0 GenomeAnalysisTK/4.1.9.0
module load tabix vcftools

################
## Reads mapping
###############

echo "--> Start triming and mapping sample"
while IFS= read -r prefix; do
    echo $prefix
    cutadapt -j ${nbThread} -a AGATCGGAAGAGCACACGTCTGAA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -q 30 -m 50 --max-n 0 -Z -o ${prefix}.R1.fastq.gz -p ${prefix}.R2.fastq.gz ${prefix}_L001_R1_001.fastq.gz ${prefix}_L001_R2_001.fastq.gz
    rg=$(echo '@RG\tID:'${prefix}':foo\tSM:'${prefix})
    bwa mem -R $rg -t ${nbThread} /pasteur/zeus/projets/p02/TRANSPOSON/josquin/aegypti/popgen/aaegL5/aaegL5_bwa_index/aaegL5.genomic.fasta ${prefix}.R1.fastq.gz ${prefix}.R2.fastq.gz | samtools view -b - | samtools sort - -o ${prefix}.sort.bam
    samtools index ${prefix}.sort.bam
done < $fastqList

###############
## SNP calling
##############

# Haplotypecaller
echo "--> run GATK Haplotypecaller, wait all jobs to finish"
job_id=$(sbatch template.gatk.txt $fastqList)

# Wait for the job to complete
while squeue | egrep daron | egrep "ampgatk" ; do
    sleep 60  # poll every 10 seconds
done

# Combine gcvf into VCF
while IFS= read -r prefix; do
    infiles="${infiles} -V ${prefix}.g.vcf.gz "
done < $fastqList

#echo $infiles
gatk --java-options "-Djava.io.tmpdir=./ -Xms64G -Xmx64G -XX:ParallelGCThreads=2" CombineGVCFs -R /pasteur/zeus/projets/p02/TRANSPOSON/ressources/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta $infiles -O $runName.gvcf.gz
gatk --java-options "-Djava.io.tmpdir=./ -Xms64G -Xmx64G -XX:ParallelGCThreads=2" GenotypeGVCFs -R /pasteur/zeus/projets/p02/TRANSPOSON/ressources/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta -V $runName.gvcf.gz -O $runName.raw.vcf.gz
gatk --java-options "-Djava.io.tmpdir=./ -Xms64G -Xmx64G -XX:ParallelGCThreads=2" VariantFiltration -R /pasteur/zeus/projets/p02/TRANSPOSON/ressources/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta -V $runName.raw.vcf.gz -O $runName.passQC.tmp.vcf.gz --filter-name "LOW_QUAL" --filter-expression "QD < 5.00 || FS > 60.000 || ReadPosRankSum < -8.000 "
zcat $runName.passQC.tmp.vcf.gz | egrep -v "LOW_QUAL" | bgzip > $runName.passQC.vcf.gz
vcftools --gzvcf $runName.passQC.vcf.gz --minGQ 30 --minDP 10 --recode-INFO-all --recode --stdout | bgzip > $runName.passQC.GQ30DP10.vcf.gz
vcftools --gzvcf $runName.passQC.GQ30DP10.vcf.gz --missing-site --stdout | awk '{if($6<0.1){print $1"\t"$2-1"\t"$2}}' > bed
bedtools intersect -a ../amplicon.loci.bed -b bed -wb | cut -f 5,7 > pos
vcftools --gzvcf $runName.passQC.GQ30DP10.vcf.gz --positions pos --missing-indv --stdout | awk '{if($5<0.1){print $1}}' > keep
vcftools --gzvcf $runName.passQC.GQ30DP10.vcf.gz --positions pos --keep keep --recode-INFO-all --recode --stdout | bgzip > $runName.passQC.GQ30DP10.lmiss10.imiss10.vcf.gz

rm $runName.passQC.tmp.vcf.gz bed keep pos

########
## Stats
########

# stats on the number of SNPs per sample
rm ${runName}.nbSNPs.txt
while IFS= read -r prefix; do
    vcftools --gzvcf $runName.passQC.GQ30DP10.vcf.gz --keep <(echo $prefix) --non-ref-ac 1 --recode --stdout  | egrep -v "#" | wc -l | awk -v var=$prefix '{print var"\t"$1}' >> ${runName}.nbSNPs.txt
done < $fastqList

# stats on amplicon coverage

rm ${runName}.ampliconCoverage.txt ${runName}.offtarget.txt

while IFS= read -r prefix; do
    bedtools intersect -a /pasteur/zeus/projets/p02/TRANSPOSON/josquin/pilgrim/amplicon/amplicon.loci.bed -b ${prefix}.sort.bam -c | awk -v var=${prefix} '{print var"\t"$0}' >> ${runName}.ampliconCoverage.txt

    samtools view -h -q 30 ${prefix}.sort.bam | samtools sort - -o ${prefix}.uniquely.sort.bam
    bedtools intersect -a /pasteur/zeus/projets/p02/TRANSPOSON/josquin/pilgrim/amplicon/amplicon.loci.complement.bed -b ${prefix}.sort.bam -c | sumcalc.pl -f 4 | awk -v var=${prefix} '{print var"\t"$3}' > ${prefix}.1.offtarget.txt
    bedtools intersect -a /pasteur/zeus/projets/p02/TRANSPOSON/josquin/pilgrim/amplicon/amplicon.loci.complement.bed -b ${prefix}.uniquely.sort.bam -c | sumcalc.pl -f 4 | awk -v var=${prefix} '{print var"\t"$3}' > ${prefix}.2.offtarget.txt
    paste ${prefix}.1.offtarget.txt ${prefix}.2.offtarget.txt | cut -f 1,2,4 >> ${runName}.offtarget.txt
    rm ${prefix}.1.offtarget.txt ${prefix}.2.offtarget.txt ${prefix}.uniquely.sort.bam
done < $fastqList

# stats on reads mapping 
rm ${runName}.statMap.*.txt

while IFS= read -r prefix; do
    zcat ${prefix}_L001_R1_001.fastq.gz | wc -l | awk '{print $1/4}' >> ${runName}.statMap.1.txt
    zcat ${prefix}.R1.fastq.gz | wc -l | awk '{print $1/4}' >> ${runName}.statMap.2.txt
    samtools stats ${prefix}.sort.bam > ${prefix}.bam.stats 
    egrep "reads unmapped:|reads mapped:" ${prefix}.bam.stats | sed 's, ,_,g' | tr "\n" "\t" | cut -f 3,6 >> ${runName}.statMap.3.txt
    rm ${prefix}.bam.stats
done < $fastqList

sumcalc.pl -grp 1 -f 6 ${runName}.ampliconCoverage.txt | cut -f 1,3 | sort -k 1,1 | cut -f 2 > ${runName}.statMap.4.txt

paste $fastqList ${runName}.statMap.1.txt ${runName}.statMap.2.txt ${runName}.statMap.3.txt ${runName}.statMap.4.txt | cut -f 1- > $runName.seq.map.stats.txt
rm ${runName}.statMap.1.txt ${runName}.statMap.2.txt ${runName}.statMap.3.txt ${runName}.statMap.4.txt

