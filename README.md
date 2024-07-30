# Variant-Calling Whole Genome Sequencing Pipeline
A rough variant-calling WGS pipeline that uses GATK best practices.
## General Information
This pipeline is ran through bash. It accepts a sample's fastq files and returns a .tsv file of the filtered variants. It will take the fastq files and run them through quality control, trimming (optional), sequence alignment, alignment clean-up, variant calling and finally filtering and annotating. 
## Packages and Files
**Important note: All packages and files in this section should be downloaded and or produced prior to running the pipeline.**
### Packages
* fastqc - version 0.11.9 - quality control package that produces a QC report. ***sudo apt install fastqc***
* trimmomatic - version 0.39 - package that will trim the reads in order to have good quality results. Can be downloaded from official website: [trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic). ***download binary file for version 0.39.*** ***Trimmomatic is a Java application, make sure system has Java installed. Can be done using: sudo apt install default-jre***
* bwa - version 0.7.17-r1188 - package used for alignment. ***sudo apt install bwa***
* samtools - version 1.13 - package used for various purposes, mainly to convert SAM file to a sorted BAM file. ***sudo apt install samtools***
* GATK - version 4.5.0.0 - main package of pipeline, used for variant calling steps. Can be downloaded from GATK website. [gatk 4.5.0.0](https://github.com/broadinstitute/gatk/releases). _scroll to version 4.5.0.0 and download zip file._
### Files
* genome reference file. Good one to use: UCSC hg38 reference file from from the iGenomes website [hg38 reference](https://support.illumina.com/sequencing/sequencing_software/igenome.html) ***scroll down to "homo sapiens"***.
* genome.fa.fai file: can be produced using samtools command --> ***samtools faidx path/to/genome/reference/file***
* genome dictionary file (genome.dict): can be produced using samtools command --> ***samtools dict -o genome.dict path/to/genome/reference/file***
* dbSNP file(s). Multiple dbSNP files can be used. Good file to use: [dbSNP hg38](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0). File name is "homo_sapien_assembly38.dbSNP138.vcf"
* dbSNP dictionary file: Can be produced using gatk command --> ***gatk IndexFeatureFile -I path/to/dbSNP/file***
 ## Steps to using the pipeline:
1. Download GATK_VariantCalling_Pipieline.sh script.
2. Install necessary packages (fastqc, trimmomatic, bwa, samtools, gatk).
3. Once trimmomatic and gatk packages are installed (refer to **Packages** section in README ), extract their respective zip files into directory where pipeline will be run.
4. Locate the gatk executable file and either add that to the system's path or create a symbolic link. The pipeline assumes it can use the gatk command from any directory.
5. Download genome reference file and use _samtools_ package to create genome.fa.fai and genome.dict files as per instructions in **Files** section of README.
6. Give the GATK_VariantCalling_Pipeline script excutable premission. ***chmod +x GATK_VariantCalling_Pipeline.sh***
7. Change the directory to wherever the script is then run the script: ***./GATK_VariantCalling_Pipeline.sh***
   The script takes in 6 total inputs:
    * path to read 1 file
    * path to read 2 file
    * path to trimmomatic executable file
    * path to adapter file from trimmomatic package
    * path to genome reference file
    * path to dbSNP file
