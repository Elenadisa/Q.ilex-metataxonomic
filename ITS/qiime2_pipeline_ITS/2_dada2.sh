#! /usr/bin/env bash


source activate qiime2-2023.5

#https://docs.qiime2.org/2024.5/plugins/available/dada2/index.html

#--p-trunc-len Position at which forward read sequences should be truncated due to decrease in quality. This value is choosen by visualizing paired-end-demux.qzv file in qiime viewer
#--p-n-threads: The number of threads to use for multithreaded processing. If 0 is provided, all available cores will be used.
#--p-chimera-method choose the way the chimeras will be removed

mkdir dada2

#filter by position
qiime dada2 denoise-paired \
	--i-demultiplexed-seqs cutadapt/demux-trimmed.qza \
	--p-trim-left-f 0 \
	--p-trim-left-r 0 \
	--p-trunc-len-f 250 \
	--p-trunc-len-r 220 \
	--p-pooling-method pseudo \
	--p-chimera-method consensus \
	--o-representative-sequences dada2/RepSeqTable.qza \
	--o-table dada2/FeatureTable.qza \
	--o-denoising-stats dada2/denoising-stats.qza \
	--verbose \
	--p-n-threads 0

#export feature table as biom format
qiime tools export \
  --input-path dada2/FeatureTable.qza \
  --output-path dada2/exported

qiime feature-table summarize \
  --i-table dada2/FeatureTable.qza \
  --o-visualization dada2/FeatureTable.qzv

qiime metadata tabulate \
  --m-input-file dada2/denoising-stats.qza \
  --o-visualization dada2/denoising-stats.qzv
