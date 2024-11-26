#! /usr/bin/env bash

#Author: Elena D. Díaz-Santiago
#This scripts perform steps in qiime2 analysis:
	#3. Assing taxonomy


source activate qiime2-2023.5

#Download (https://docs.qiime2.org/2024.5/data-resources/) or pretrain (https://docs.qiime2.org/2024.5/tutorials/feature-classifier/) the clasiffier: 

mkdir taxonomy


#Taxonomy len1
qiime feature-classifier classify-sklearn \
  --i-classifier ../taxonomy_classifiers/unite_ver9_dynamic_all_25.07.2023-Q2-2023.5.qza \
  --i-reads dada2/RepSeqTable.qza \
  --o-classification taxonomy/taxonomy.qza \
  --p-reads-per-batch 1000 \
  --p-n-jobs 1

#export taxonomy table to biom format
qiime tools export \
  --input-path taxonomy/taxonomy.qza \
  --output-path taxonomy/exported

# Filter not classified at phylum level and Fungi Kingdom and update Feature table and RepSeqTable
qiime taxa filter-table \
  --i-table dada2/FeatureTable.qza  \
  --i-taxonomy taxonomy/taxonomy.qza \
  --p-include "k__Fungi;p__" \
  --p-exclude "k__Fungi;p__unidentified" \
  --o-filtered-table taxonomy/final_FeatureTable.qza

#Obtain sequences of retained OTUS
qiime feature-table filter-seqs \
  --i-data dada2/RepSeqTable.qza \
  --i-table taxonomy/final_FeatureTable.qza \
  --o-filtered-data taxonomy/final_RepSeqTable.qza

qiime tools export \
  --input-path taxonomy/final_FeatureTable.qza \
  --output-path taxonomy/exported

#collapse data at genus level
qiime taxa collapse \
  --i-table taxonomy/final_FeatureTable.qza \
  --i-taxonomy taxonomy/taxonomy.qza\
  --o-collapsed-table taxonomy/FeatureTable_collapsed.qza \
  --p-level 6



