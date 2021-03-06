library(lubridate)
library(stringr)
library(readr)
library(dplyr)
library(tibbletime)
library(scales)
options(error = function() traceback(2))

setwd("/home/at062084/DataEngineering/COVID-19/COVID-19-Austria/bmsgpk")
source("../COVID-19-common.R")


# do some logging
logFile <- "./COVID-19-covid-county-extract.log"
logMsg <- function(msg) {
  #cat(paste(format(Sys.time(), "%Y%m%d-%H%M%OS3"), msg, "\n"), sep="", file=logFile, append=TRUE)
  cat(paste(format(Sys.time(), "%Y%m%d-%H%M%OS3"), msg, "\n"), sep="")
}


# -------------------------------------------------------------------------------------------------------------
covCounty <- function(scrapeStamp=now(), dataDate=format(scrapeStamp,"%Y-%m-%d"), dataDir="./data") {
# -------------------------------------------------------------------------------------------------------------  
  
  # -------------------------------------------------------------------------------------------------------------
  # Data files for country and state
  # -------------------------------------------------------------------------------------------------------------
  
  # read data for Confirmed
  csvFile <- "/home/at062084/DataEngineering/COVID-19/COVID-19-Austria/bmsgpk/data/COVID-19-austria.csv"
  da <- read.csv(csvFile, stringsAsFactors=FALSE) %>% 
    dplyr::mutate(Stamp=as.POSIXct(Stamp)) %>%
    dplyr::filter(date(Stamp)==as.POSIXct(dataDate))
  
  
  # read data for Hospitalized. Data now already in above file
  csvFile <- "/home/at062084/DataEngineering/COVID-19/COVID-19-Austria/bmsgpk/data/COVID-19-austria.hospital.csv"
  dh <- read.csv(csvFile, stringsAsFactors=FALSE) %>% 
    dplyr::mutate(Stamp=as.POSIXct(Stamp)) %>%
    dplyr::filter(date(Stamp)==as.POSIXct(dataDate)) %>%
    dplyr::distinct()
  
  
  # Merge these data and select last record of each Status per day
  df <- rbind(da,dh) %>% 
    dplyr::mutate(Date=date(Stamp)) %>%
    dplyr::arrange(Stamp) %>%
    dplyr::group_by(Date,Status) %>%
    dplyr::filter(row_number()==1) %>%
#    dplyr::filter(!is.na(AT)) %>%
    dplyr::ungroup()

  # check if all required data available
  failStamp <- max(df$Stamp)
  for (s in c("Tested","Confirmed","Recovered","Deaths","Hospitalisierung","Intensivstation")) {
    nr <- nrow(df)
    if (!s %in% df$Status) {
      df[nr+1,"Status"] <- s
      df[nr+1,"Stamp"] <- failStamp
    }
  }
  
  # -------------------------------------------------------------------------------------------------------------
  # Write Data file for country 
  # -------------------------------------------------------------------------------------------------------------
  
  # simplified format for PR
  ds <- df %>% 
    dplyr::select(Date,Status,AT) %>%
    tidyr::spread(key=Status, val=AT) %>%
    dplyr::mutate(country="AT",county="ALL",state="ALL") %>%
    dplyr::rename(cases=Confirmed, deaths=Deaths,tested=Tested, recovered=Recovered, hospitalized=Hospitalisierung) %>%
    dplyr::select(-Intensivstation, -Date) %>% 
    dplyr::select(country,county,state,cases,deaths,recovered,tested,hospitalized)
  
  # Write country file for covid-county
  fileName <- paste0(dataDir,"/AT_country.bmsgpk.csv")
  logMsg(paste("Writing", fileName))
  write.csv(ds, file=fileName, quote=FALSE, row.names=FALSE)


  # -------------------------------------------------------------------------------------------------------------
  # Write Data file for states
  # -------------------------------------------------------------------------------------------------------------
  colnames(df) <- c(colnames(df)[1:2],"ALL",BL$ISO[2:10],"Date")
  
  # simplified format
  dg <- df %>%
    dplyr::select(-Stamp) %>%
    dplyr::filter(Status!="Intensivstation") %>%
    tidyr::gather(key=state,val=Count,2:11) %>%
    tidyr::spread(key=Status, val=Count) %>%
    dplyr::mutate(country="AT", county="ALL") %>%
    dplyr::rename(cases=Confirmed, deaths=Deaths, hospitalized=Hospitalisierung, recovered=Recovered, tested=Tested) %>%
    dplyr::select(-Date) %>%
    dplyr::select(country,state,county,cases,deaths,recovered,tested,hospitalized)
  
  # Write state file for covid-county
  fileName <- paste0(dataDir,"/AT_states.bmsgpk.csv")
  logMsg(paste("Writing", fileName))
  write.csv(dg, file=fileName, quote=FALSE, row.names=FALSE)
  
  
  # -------------------------------------------------------------------------------------------------------------
  # Write Data file for counties (regions, Bezirke)
  # -------------------------------------------------------------------------------------------------------------
  # read data for Bezirke
  csvFile <- "/home/at062084/DataEngineering/COVID-19/COVID-19-Austria/bmsgpk/data/COVID-19-austria.regions.csv"
  dr <- read.csv(csvFile, stringsAsFactors=FALSE) %>% 
    dplyr::mutate(Stamp=as.POSIXct(Stamp)) %>%
    dplyr::filter(date(Stamp)==as.POSIXct(dataDate))
  
  dt <- dr %>% 
    dplyr::mutate(Date=date(Stamp)) %>%
    dplyr::arrange(Stamp) %>%
    dplyr::group_by(Date,Status,Region) %>%
    dplyr::filter(row_number()==1) %>%
    dplyr::ungroup() %>%
    dplyr::inner_join(OBR, by=c("Region"="Bezirk")) %>%
    dplyr::group_by(Date,Status,NUTS0,NUTS2,NUTS3) %>% 
    dplyr::summarize(Count=sum(Count)) %>% 
    dplyr::ungroup() %>%
    dplyr::select(country=NUTS0,state=NUTS2,county=NUTS3,cases=Count) %>%
    dplyr::arrange(country,state,county)
  
  # append to box format
  fileName <- paste0(dataDir,"/AT_counties.bmsgpk.csv")
  logMsg(paste("Writing", fileName))
  write.csv(dt, file=fileName, quote=FALSE, row.names=FALSE)
}


# --------------------------------------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------------------------------------

# Convert data to covid-county format and write into three csv files
logMsg(paste("Running COVID-19-covid-county-extract.R"))

ts <- now()-hours(2)
logMsg(paste("Executing covCounty with", ts))
covCounty(scrapeStamp=ts, dataDate=format(ts,"%Y-%m-%d"), dataDir="./data")
logMsg("Done executing covCounty")
logMsg("Done running COVID-19-covid-county-extract.R")



