#' R Translation of PRMS Post Processing Script
#'
#' Applied to modeled streamflow outputs from PRMS for SFPUC reservoirs
#' 
#' This takes some liberties within the R environment as R version doesn't have prepared data objects similar to what MATLAB version has.
#' 
#'  Original MATLAB: Reggie Walters, SFPUC, 2016
#'  Translated R: Don Park, UMass Team, 2020

# Initialization
library(tidyverse)
library(zoo)
library(xts)

EP <- seq(from = as.Date('1971-10-01'), to = as.Date('2015-09-30'), by = 'days')

Obs <- read_csv(file.path('datastore', 'UpCountryClimate.csv'))

Flow <- read_csv(file.path('datastore', 'FLOW_OBSVAL_UC_197010-201509.csv'))

# Loading CPI Function
source(file.path('R', 'CPI.R'))

# Data Preparation
# This generates QMOD_ALL, allMonths, tIndex, pcpIndex, and TSS
source(file.path('RScript', 'PRMS_DataPrep.R'))

# Loads fitting parameters for polynomial adjustment function
# Generates initial data sets
source(file.path('RScript', 'PRMS_fitting.R'))


# Iteration for each model
for(j in 1:nM) {
  
  # jth modeled streamflow
  QMOD <- QMOD_ALL[,j]
  
  # Container for the post-processing output
  QMOD_PP <- QMOD
  
  # Compute B-C transfomration of the model data
  Z_mod <- ((QMOD + coeff[j])^Lambda - 1) / Lambda
  
  # Compute Current Precip Index (CPI) for Model j
  Beta <- Beta_Array[j] # j'th Beta Parameter
  CPIndex <- CPI(pcpIndex, Beta, dt) # compute CPI
  cpi <- as.vector(xts::xts(CPIndex$ci, order.by = CPIndex$time)[EP])
  
  # iterate over each column in PMonths [N = 3] and apply corrections
  for(q in 1:dim(PMonths)[2]) {
    
    # get indices in allMonths array corresponding to months in column q
    #   that is, retrieve all indices with months appearing in column q
    #   of the 'PMonths' matrix
    m_i <- allMonths %in% PMonths[,q]
    
    # get the CPI and TSS values for the m_i indices
    mCPI <- cpi[m_i]
    mTI <- TSS[m_i]
    
    # get the transformed model data for the m_i indices
    Z_i <- Z_mod[m_i]
    
    # get the model fit parameters for model j and temporal bin q
    P = P_ALL[, q, j]
    
    # Apply post-processing function to all transformed model data in subset Z_i
    eta <- P[1] * mCPI * mTI + P[2] * mTI + P[3] * mCPI + P[4] # Emperical multilinear error model
    Z_Ana <- Z_i + eta # updated transformed model
    QMOD_PP[m_i] <- (Lambda * Z_Ana + 1)^(1/Lambda) - coeff[j]
  }
  
  # Update the j'th column in the post-processed model output array
  QMOD_ALL_PP[,j] <- QMOD_PP
}
