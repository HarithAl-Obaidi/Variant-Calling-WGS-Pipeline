# Variant-Calling Whole Genome Sequencing Pipeline
A rough variant-calling WGS pipeline that uses GATK best practices.
## General Information
A wgs variant-calling pipeline that includes quality control, trimming, sequence alignment, alignment clean-up, variant calling and finally filtering and annotation. 
The pipeline accepts a sample's fastq files and generates a filtered variants.vcf.tsv table
This pipeline uses the GATK package best practices ("AddOrReplaceGroups", "ApplyBQSR", "HaplotypeCaller", etc...).
## 
