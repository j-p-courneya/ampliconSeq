# ampliconSeq
This repository provides tools and workflows for genotyping polymorphisms from short-read sequencing data generated from an amplicon panel dedicated to Aedes Aegypti.

## Mandatory tools
Here is the list of mandatory tools that need to be present in the path to launch succesfully the ampliconseq analysis workflow.
cutadapt (4.9)
bwa (0.7)
samtools (1.21)
bedtools (v2.31.1)
GenomeAnalysisTK (4.1.9.0)
VCFtools (0.1.16)

## Workflow
To launch the workflow just run the command bellow.<br>
ARG#1 is a list of prefix name of the FASTQ input file.
ARG#1 is just the name of the run. 

bash ampliconProcessing.sh <LIST> <STR>
