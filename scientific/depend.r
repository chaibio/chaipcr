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

qpcR_funcs <- c(
                #'modlist_R0.r', 'getPar_R1.r', 'utils_R1.R', # customized, for testing
                'modlist_R1.r', 'getPar_R1.r', 'utils_R1.R', # customized
                #'modlist.r', 'getPar.r', 'utils.R', # original
                'AICc.R', 'Cy0.R', 'eff.R', 'efficiency.R', 'expfit.R', 'KOD.r', 'meltcurve.r', 'midpoint.R', 'pcrfit.r', 'predict.pcrfit.r', 'replist.r', 'resVar.R', 'RMSE.R', 'Rsq.ad.r', 'Rsq.R', 'sliwin.R', 'takeoff.R')
                # (not used) 'akaike.weights.R', 'calib.r', 'evidence.R', 'expcomp.R', 'expfit.R', 'fitchisq.r', 'is.outlier.r', 'llratio.r', 'LOF.test.r', 'LRE.r', 'maxRatio.r', 'meltcurve.r', 'mselect.r', 'pcrbatch.r', 'pcrboot.r', 'pcrGOF.R', 'pcrimport.R', 'pcrimport2.R', 'pcropt1.R', 'pcrpred.R', 'pcrsim.r', 'plot.pcrfit.r', 'PRESS.R', 'propagate.R', 'qpcR.news.r', 'ratiobatch.r', 'ratiocalc.r', 'ratioPar.r', 'refmean.R', 'resplot.R', 'resVar.R', 'RSS.R', 'update.pcrfit.r') # dir('E:/WVU1/Dropbox/pRgRamNotes/R_resources/qpcR/R') and remove 'sysdata.rda'

dummy <- lapply(paste('qpcR', qpcR_funcs, sep='/'), source)

load('qpcR/sysdata.rda')


# set constants
num_wells <- 16
scaling_factor <- 9e5


