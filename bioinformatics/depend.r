# load dependencies for 'amp.r' and 'meltcrv.r'


# load libraries
library(plyr)
#library(qpcR)
library(reshape2)
library(RMySQL)


# load dependencies from qpcR but not the whole package

library(MASS)
library(minpack.lm)
#library(rgl)
library(robustbase)
library(Matrix)
library(DBI)

#setwd(Sys.getenv('RWORKDIR')) # Xia Hong

dpds <- dir(pattern='\\.[Rr]$', recursive=TRUE)
dpds <- dpds[dpds != 'depend.r']
dummy <- lapply(dpds, source) # recursively load all the files that ends with '.R' or '.r'

load('qpcR/sysdata.rda')


# set constants
num_wells <- 16
scaling_factor <- 9e5


