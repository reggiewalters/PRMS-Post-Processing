#' Current Precipitation Index (CPI)
#'
#' As described in:
#'  Smakhtin, V. Y., Masse, B. 2000. Continuous 
#'  daily hydrograph simulation using duration
#'  curves of a precipitation index.Hydrological
#'  Processes 14: 1083-1100.
#'  
#'  Original MATLAB: Reggie Walters, SFPUC, 2016
#'  Translated R: Don Park, UMass Team, 2020
#'  
#'  @param prcp Instantaneous precipitation time series vector
#'  @param beta Recession coefficient
#'  @param time Time array corresponding to precipitation input series 
#'  
#'  @return Dataframe with CPI and Time
#'  @export

CPI <- function(prcp, beta, time) {
  
  c_i <- rep(0, length(prcp))
  
  for(i in 2:length(c_i)) {
    c_i[i] <- prcp[i-1] + beta * c_i[i-1]
  }
  
  return(data.frame(time = time, ci = c_i))
  
  
}

