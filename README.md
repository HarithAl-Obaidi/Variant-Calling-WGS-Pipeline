# Variant-Calling Whole Genome Sequencing Pipeline
A rough variant-calling WGS pipeline that uses GATK best practices.
## General Information
This pipeline is ran through bash. It accepts a sample's fastq files and returns a tsv file of the filtered variants. It will take the fastq files and run them through quality control, trimming (optional), sequence alignment, alignment clean-up, variant calling and finally filtering and annotating. It uses the GATK best practices.
## 
