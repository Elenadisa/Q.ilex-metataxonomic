#! /usr/bin/env bash

#Author: Elena D. Díaz-Santiago
#This scripts perform steps in qiime2 analysis:
	#4. Phylogeny


source activate qiime2-2023.5

mkdir phylogeny

#Alignment
qiime alignment mafft \
  --i-sequences taxonomy/final_RepSeqTable.qza \
  --o-alignment phylogeny/aligned-rep-seqs.qza

#Reducing alignment ambiguity
#remove positions that are highly variable. These positions are generally considered to add noise to a resulting phylogenetic tree.

qiime alignment mask \
  --i-alignment phylogeny/aligned-rep-seqs.qza \
  --o-masked-alignment phylogeny/masked-aligned-rep-seqs.qza


#create the tree using the Fasttree program
qiime phylogeny fasttree \
  --i-alignment phylogeny/masked-aligned-rep-seqs.qza \
  --o-tree phylogeny/unrooted-tree.qza

#root the tree using the longest root
qiime phylogeny midpoint-root \
  --i-tree phylogeny/unrooted-tree.qza \
  --o-rooted-tree phylogeny/rooted-tree.qza
