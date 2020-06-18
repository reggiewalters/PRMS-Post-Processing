#' This script creates:
#' 
#' QMOD_ALL
#' tIndex
#' pcpIndex

# Configuration
prcp <- c('HTH', 'BKM', 'TUM', 'CVM', 'MCN', 'PCR', 'YOS', 'GNL', 'Intake')
prcpObs <- c('HHprecip', 'BKMprecip', 'TUMprecip', 'CVMprecip', 'MCNprecip', 'PCRprecip', 'YOSprecip', 'GNLprecip', 'Intake')
temp <- c('HTH', 'BKM', 'TUM', 'CVM', 'MCN', 'PDS', 'HRS', 'SLI', 'PCR')
tempObs <- c('HH', 'BKM', 'TUM', 'CVM', 'MCN', 'PDS', 'HRS', 'SLI', 'PCR')

# 
aftocfs <- function(data, ts = 86400) {
  
  return((data * 43560) / ts)
}


# Handling Flow Data for QMOD_ALL
QHH <- aftocfs(xts::xts(Flow$flow_HHModNoBC_acf, order.by = Flow$Date)[EP])
QCH <- aftocfs(xts::xts(Flow$flow_CEModNoBC_acf, order.by = Flow$Date)[EP])
QDP <- aftocfs(xts::xts(Flow$flow_DPModNoBC_acf, order.by = Flow$Date)[EP])
QLAG <- aftocfs(xts::xts(Flow$flow_HHModNoBC_acf + Flow$flow_CEModNoBC_acf + Flow$flow_DPModNoBC_acf, order.by = Flow$Date)[EP])

QMOD_ALL <- read.zoo(tibble(Date = index(QHH), QHH = as.vector(QHH), QCH = as.vector(QCH), QDP = as.vector(QDP), QLAG = as.vector(QLAG)))

QMOD_ALL_PP <- QMOD_ALL # Container for the post-processing outputs

# Handling Date Extraction as DV and allMonths
DV <- tibble(year = format(EP, '%Y'), month = format(EP, '%m'), day = format(EP, '%d'), hour = 0, minute = 0, second = 0)

allMonths <- as.numeric(DV$month)

# Handling Meteorology Data
dt <- Obs$Date

obsClimateData <- list()
for(variable in c('prcp', 'tmax', 'tmin', 'tavg')) {
  
  # Handling Observed Data
  if(variable == 'prcp') {
    prcpObsColSelect <- c('Date', prcpObs)
    df <- Obs %>% select(tidyselect::all_of(prcpObsColSelect))
    colnames(df) <- c('Date', prcp)
  } else if(variable == 'tmax') {
    tmaxObsColSelect <- c('Date', paste0(tempObs, 'max'))
    df <- Obs %>% select(tidyselect::all_of(tmaxObsColSelect))
    colnames(df) <- c('Date', temp)
  } else if(variable == 'tmin') {
    tminObsColSelect <- c('Date', paste0(tempObs, 'min'))
    df <- Obs %>% select(tidyselect::all_of(tminObsColSelect))
    colnames(df) <- c('Date', temp)
  } else if(variable == 'tavg') {
    df <- Obs %>% 
      mutate(HTH = (HHmax + HHmin)/2, BKM = (BKMmax + BKMmin)/2, TUM = (TUMmax + TUMmin)/2,
             CVM = (CVMmax + CVMmin)/2, MCN = (MCNmax + MCNmin)/2, PDS = (PDSmax + PDSmin)/2, 
             HRS = (HRSmax + HRSmin)/2, SLI = (SLImax + SLImin)/2, PCR = (PCRmax + PCRmin)/2) %>%
      select(tidyselect::all_of(c('Date', temp)))
  } else stop(paste0('Variable: ', variable, ' is unknown in XTS Handling Loop'))
  
  
  obsClimateData[[variable]] <- read.zoo(df)
}

tIndex <- as.vector(xts::xts(rowMeans(obsClimateData$tavg), order.by = index(obsClimateData$tavg)))
pcpIndex <- as.vector(xts::xts(rowMeans(obsClimateData$prcp), order.by = index(obsClimateData$prcp)))

TSS <- rollapplyr(tIndex, 15, sum, partial = TRUE)[EP]

