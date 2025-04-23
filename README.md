# ampliconSeq
This repository provides tools and workflows for genotyping polymorphisms from short-read sequencing data generated from an amplicon panel dedicated to Aedes Aegypti.<br>

## Mandatory tools
Here is the list of mandatory tools that need to be present in the path to launch succesfully the ampliconseq analysis workflow.<br>
cutadapt (4.9)<br>
bwa (0.7)<br>
samtools (1.21)<br>
bedtools (v2.31.1)<br>
GenomeAnalysisTK (4.1.9.0)<br>
VCFtools (0.1.16)<br>

## Workflow
To launch the workflow just run the command bellow.<br>
ARG#1 is a list of prefix name of the FASTQ input file.<br>
ARG#2 is just the name of the run.<br>

bash ampliconSeqProcessing.sh LIST RUN_NAME<br>
