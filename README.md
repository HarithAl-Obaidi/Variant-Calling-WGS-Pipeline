# Variant-Calling Whole Genome Sequencing Pipeline
A rough variant-calling WGS pipeline that uses GATK best practices.
## General Information
This pipeline is ran through bash. It accepts a sample's fastq files and returns a .tsv file of the filtered variants. It will take the fastq files and run them through quality control, trimming (optional), sequence alignment, alignment clean-up, variant calling and finally filtering and annotating. 
## Packages and Files
### Packages
* fastqc - version 0.11.9 - quality control package that produces a QC report.
* trimmomatic - version 0.39 - package that will trim the reads in order to have good quality results. Can be downloaded from trimmomatic github page.
* bwa - version 0.7.17-r1188 - package used for alignment.
* samtools - version 1.13 - package used for various purposes, mainly to convert SAM file to a sorted BAM file.
* GATK - version 4.5.0.0 - main package of pipeline, used for variant calling steps. Can be downloaded from GATK website.
### Files
* genome reference file. UCSC hg38 reference file from from the iGenomes website is the one used but any reference file will work.
* genome.fa.fai file: can be produced using samtools command --> samtools faidx path/to/genome/reference/file
* genome dictionary file (genome.dict): can be produced using samtools command --> samtools dict -o genome.dict path/to/genome/reference/file
* dbSNP file(s). Multiple dbSNP files can be used, the one used for this pipeline is from https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0. File name is "homo_sapien_assembly38.dbSNP138.vcf"
* dbSNP dictionary file: Can be produced using gatk command --> gatk IndexFeatureFile -I path/to/dbSNP/file
## Usage
Once all packages are downloaded, all the files needed can be downloaded/produced. The files from the "files needed" section should be produced prior to running the pipeline. 

Creating a symbolic link to the gatk file is needed for the pipeline to function properly as it assumes that it can use the gatk package regardless of what directory the user is in.

### Steps to using the pipeline:
1. Download script.
2. Download packages needed.
3. Extract gatk.tar.gz files to a directory.
4. Locate the gatk executable file and either add that to the system's path or create a symbolic link. 
5. Download files that can be downloaded from "Files" section.
6. Produce the dictionary and index files needed from the "Files" section.
7. Give the bash script excutable premission.
8. While in the script's directory, run the script:
   The script takes in 6 total inputs:
    * path to read 1
    * path to read 2
    * path to trimmomatic executable file
    * path to adapter file from trimmomatic package
    * path to genome reference file
    * path to dbSNP file
