# Q.ilex-metataxonomic

This repository stores the code available to perform an amplicon analysis with QIIME2 and downstream analysis with R.  
This code can be run in any Linux system. However, if you are a Windows user you need to run QIIME2 part in WSL.  
  
## Download and Install QIIME2  
This analysis was performed with QIIME2 2023.5 version. To install QIIME2 follow the [instructions](https://docs.qiime2.org/2023.5/install/index.html).  
In case you want to use updated version of QIIME2 install amplicon version.  

## Download pretrained classifiers  
We used SILVA and UNITE pretrained classifiers that are available at [QIIME2 web](https://docs.qiime2.org/2023.5/data-resources/). Create a taxonomy_classifier directory and save the .qza files inside. 
  
```{bash }
mkdir taxonomy_classifier

curl https://data.qiime2.org/2023.5/common/silva-138-99-nb-classifier.qza -o taxonomy_classifier/silva-138-99-nb-classifier.qza
curl https://github.com/colinbrislawn/unite-train/releases/download/v9.0-v25.07.2023-qiime2-2023.5/unite_ver9_dynamic_all_25.07.2023-Q2-2023.5.qza -o taxonomy_classifier/unite_ver9_dynamic_all_25.07.2023-Q2-2023.5.qza
```
  
Make sure that the name of the classifiers correspond to the paths in:
  
```{bash }
16S/qiime2_pipeline_16S/3_assing_taxonomy.sh   #line 14

ITS/qiime2_pipeline_ITS/3_assing_taxonomy.sh   #line 17
```


## Download R and RStudio  
R analysis can be run in any computer.  
Donwload [R](https://cran.r-project.org/bin/windows/base/), and also you can download [RStudio](https://posit.co/download/rstudio-desktop/) in case you do not want to use command-line.  
  
### Install R packages  
Before to start the analysis you need to install the following CRAN packages:  

```{r }
install.packages(c("ggplot2", "ggpubr", "ggVennDiagram" "rmarkdown", "gridExtra", "kableExtra", "dplyr", "magrittr", "multcompView"))
``` 
  
Furthermore, these bioconductor packages should be installed using the the BiocManager package:  

```{r }
BiocManager::install(c("phyloseq", "microbiomeMarker", "microeco", "microbiome", "metagenomeSeq", "file2meco"))
```
  
Also, you may download other packages from github:  
  
```{r }
install.packages('devtools')
library(devtools)
install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
install_github("jbisanz/qiime2R")
```

## Execution Details  
Scripts for 16S and ITS analysis are available in the directory with its corresponding names. 
**1.** First you need to execute QIIME2. The scripts are available in qiime2_pipeline_16S/ITS directory. You need to execute the scripts in order:  
- The fist script import the sequences in QIIME2 and execute cutadapt pluggin.  
- The second script execute DADA2 plugin.  
- The third script assing the taxonomy.  
- The fourth script generate the phylogenetic tree.  
  
**2.** Run Rmkardown template.  
With QIIME2 output we can perform different analysis. The markdown template contains the code for downstream analysis and generates a report in HTML. You have to ways to obtain the reports:   
- RStudio:
Open RStudio, set the working directory and execute the following commands:  
  
```{r}
library(rmarkdown)

#for 16S analysis
setwd(PATH/TO/16S)
render("16S_report.Rmd")

#for ITS analysis
setwd(PATH/TO/ITS)
render("16S_report.Rmd")
```

- Command line:  
To compile the HTML report in a command line use the followin command:

```{bash }
Rscript rmarkdown::render('16S_report.Rmd')
Rscript rmarkdown::render('ITS_report.Rmd')
```

Do not forget to set the path for the functions.R file before to compile the reports. Moreover, you need to excute the reports in 16S or ITS directory in order to have QIIME2 outputs accesible for the reports. In case you customize QIIME2 output modify the path to the files needed in the reports templates.  
  
## Citation

If you use some of the code available in this repository please cite this article:
