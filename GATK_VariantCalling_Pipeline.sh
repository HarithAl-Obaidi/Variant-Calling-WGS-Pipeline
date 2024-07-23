#!/bin/bash 

# Sample -NA12878

mkdir VariantCalling_Pipeline #Directory where pipeline will be taking place
cd VariantCalling_Pipeline

mkdir fastqc_files #Directory where fastqc files will go

#Every file needed for the pipeline as inputs
read1=$1
read2=$2
trimmomaticfile=$3
adapterfile=$4
genomeref=$5
dbSNP=$6


#Initial fastqc
fastqc -t 2 $read1 $read2 -o fastqc_files/

read -p "Review fastqc files. Perform trimming? (y/n) " trimming

if [ "$trimming" == "y" ]; then

    java -jar $trimmomaticfile PE -phred33 $read1 $read2 trimmed_read1_paired.fastq trimmed_read1_unpaired.fastq trimmed_read2_paired.fastq trimmed_read2_unpaired.fastq ILLUMINACLIP:$adapterfile:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36

    #Post-Trimming QC
    fastqc -t 4 trimmed_read1_paired.fastq trimmed_read1_unpaired.fastq trimmed_read2_paired.fastq trimmed_read2_unpaired.fastq -o fastqc_files/

    read -p "Review trimmed fastqc files. Continue? (y/n) " continuation

    if [ "$continuation" == "y" ]; then

        #Rename trimmed reads as "clean"
        mv trimmed_read1_paired.fastq clean_read1_paired.fastq
        mv trimmed_read2_paired.fastq clean_read2_paired.fastq

        #BWA Alignment
        bwa mem -M -t 2 $genomeref clean_read1_paired.fastq clean_read2_paired.fastq > alignment_result.sam 2> bwa.err 
        
        #Conversion to BAM file
        samtools view -bS alignment_result.sam > raw_alignment_result.bam
        samtools sort raw_alignment_result.bam -o sorted.results.bam
        
        #Adding Reading Groups
        gatk AddOrReplaceReadGroups \
        --INPUT sorted.results.bam \
        --OUTPUT results_with_RG.bam \
        --RGLB lib1 \
        --RGPL ILLUMINA \
        --RGSM NA12878 \
        --RGPU unit1
        
        #Remove Duplicates
        gatk MarkDuplicates \
        --INPUT results_with_RG.bam \
        --OUTPUT results_wo_duplicates.bam \
        --CREATE_INDEX true \
        --VALIDATION_STRINGENCY SILENT \
        --METRICS_FILE metrics.txt

        #Base Recalibration
        gatk BaseRecalibrator \
        -R $genomeref \
        -I results_wo_duplicates.bam \
        --use-original-qualities \
        -O output.base_recalibrated.bam \
        -known-sites $dbSNP

        #Applying BQSR
        gatk ApplyBQSR \
        --add-output-sam-program-record \
        -R $genomeref \
        -I results_wo_duplicates.bam \
        --use-original-qualities \
        -O output.BQSR.bam \
        --bqsr-recal-file output.base_recalibrated.bam
        
        #Variant Calling
        gatk HaplotypeCaller \
        -R $genomeref \
        -I output.BQSR.bam \
        -O variants.vcf.gz \
        -dont-use-soft-clipped-bases \
        -stand-call-conf 20.0 \
        -D $dbSNP

        #Variant Filteration
        gatk VariantFiltration \
        -R $genomeref \
        -V variants.vcf.gz \
        --window 35 \
        --cluster 3 \
        --filter-name "FS" \
        --filter "FS > 30.0" \
        --filter-name "QD" \
        --filter "QD < 2.0" \
        -O filtered_variants.vcf.gz
        
        #Changing variant file to table
        gatk VariantsToTable \
        -V filtered_variants.vcf.gz \
        -F CHROM -F POS -F TYPE -GF AD \
        -O filtered_variants.vcf.tsv
        
    elif [ "$continuation" == "n" ]; then 
    echo "Script End"
    exit 
    fi

elif [ "$trimming" == "n" ]; then

    mv $read1 clean_read1_paired.fastq
    mv $read2 clean_read2_paired.fastq

    #BWA Alignment
    bwa mem -M -t 2 $genomeref clean_read1_paired.fastq clean_read2_paired.fastq > alignment_result.sam 2> bwa.err 
    
    #Conversion to BAM file
    samtools view -bS alignment_result.sam > raw_alignment_result.bam
    samtools sort raw_alignment_result.bam -o sorted.results.bam

    #Adding Reading Groups
    gatk AddOrReplaceReadGroups \
    --INPUT sorted.results.bam \
    --OUTPUT results_with_RG.bam \
    --RGLB lib1 \
    --RGPL ILLUMINA \
    --RGSM NA12878 \
    --RGPU unit1

    #Remove Duplicates
    gatk MarkDuplicates \
    --INPUT results_with_RG.bam \
    --OUTPUT results_wo_duplicates.bam \
    --CREATE_INDEX true \
    --VALIDATION_STRINGENCY SILENT \
    --METRICS_FILE metrics.txt

    #Base Recalibration
    gatk BaseRecalibrator \
    -R $genomeref \
    -I results_wo_duplicates.bam \
    --use-original-qualities \
    -O output.base_recalibrated.bam \
    -known-sites $dbSNP

    #Applying BQSR
    gatk ApplyBQSR \
    --add-output-sam-program-record \
    -R $genomeref \
    -I results_wo_duplicates.bam \
    --use-original-qualities \
    -O output.BQSR.bam \
    --bqsr-recal-file output.base_recalibrated.bam

    #Variant Calling
    gatk HaplotypeCaller \
    -R $genomeref \
    -I output.BQSR.bam \
    -O variants.vcf.gz \
    -dont-use-soft-clipped-bases \
    -stand-call-conf 20.0 \
    -D $dbSNP

    #Variant Filteration
    gatk VariantFiltration \
    -R $genomeref \
    -V variants.vcf.gz \
    --window 35 \
    --cluster 3 \
    --filter-name "FS" \
    --filter "FS > 30.0" \
    --filter-name "QD" \
    --filter "QD < 2.0" \
    -O filtered_variants.vcf.gz

    #Changing variant file to table
    gatk VariantsToTable \
    -V filtered_variants.vcf.gz \
    -F CHROM -F POS -F TYPE -GF AD \
    -O filtered_variants.vcf.tsv

fi

