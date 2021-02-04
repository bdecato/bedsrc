#!/usr/bin/env Rscript
# Script documenting my R environment setup for easy access on new machines.
# 

install.packages("reticulate")
install.packages("tidyverse")
install.packages("conflicted")
install.packages("plotly")
install.packages("devtools")
install.packages("pheatmap")
install.packages("rmarkdown")
install.packages("tinytex") # For PDF output from RMarkdown
tinytex::install_tinytex()
install.packages("ape")
install.packages("")

# Bioconductor stuff
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.12")

library(BiocManager)

BiocManager::install("SingleR")
BiocManager::install("Seurat")
BiocManager::install("infercnv")
BiocManager::install("genefu")
BiocManager::install("zinbwave")
BiocManager::install("GSVA")

library(devtools)
install_github("chrisamiller/fishplot")
install_github("navinlabcode/copykat") # Not currently in Bild lab pipeline
install_github("MathOnco/EvoFreq") # Not currently in Bild lab pipeline

# Clonevol installation
install_github("hdng/clonevol")
install.packages('gridBase')
install.packages('gridExtra')
install.packages('ggplot2')
install.packages('igraph')
install.packages('packcircles')
install_github('hdng/trees')



