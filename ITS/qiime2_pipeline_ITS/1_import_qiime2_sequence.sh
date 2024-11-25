#! /usr/bin/env bash

#Author: Elena D. Díaz-Santiago
#This scripts perform the first steps in qiime2 analysis 16S:
#1. Import data in qiime2

source activate qiime2-2023.5

mkdir demux
mkdir cutadapt
mkdir cutadapt/trimmed_fastq_files


# 1.Import data in qiime 2
#Imput format implyies no metadata and no manifest file
#We have already demultiplexed samples (one sample in each file)

qiime tools import \
 --type 'SampleData[PairedEndSequencesWithQuality]' \
 --input-path ../raw_data/ITS \
 --input-format CasavaOneEightSingleLanePerSampleDirFmt \
 --output-path demux/paired-end-demux.qza

qiime demux summarize \
 --i-data demux/paired-end-demux.qza \
 --o-visualization demux/paired-end-demux.qzv


#cutadapt remove primers:
#pfront trimmed at 5', p-adapter trimmed at 3'
#https://docs.qiime2.org/2024.5/plugins/available/cutadapt/trim-paired/
#https://forum.qiime2.org/t/q2-cutadapt-output/17031

# Primers from https://imr.bio/protocols.html

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences demux/paired-end-demux.qza \
  --p-front-f GTGAATCATCGAATCTTTGAA \
  --p-adapter-f GCATATCAATAAGCGGAGGA \
  --p-front-r TCCTCCGCTTATTGATATGC \
  --p-adapter-r TTCAAAGATTCGATGATTCAC \
  --verbose \
  --p-discard-untrimmed \
  --p-match-read-wildcards \
  --o-trimmed-sequences cutadapt/demux-trimmed.qza


qiime demux summarize \
 --i-data cutadapt/demux-trimmed.qza \
 --o-visualization cutadapt/demux-trimmed.qzv


 #extract sequences after cutadapt
 # Extracción de secuencias antes y después de cutadapt
qiime tools export --input-path cutadapt/demux-trimmed.qza  --output-path cutadapt/trimmed_fastq_files
