library(RCurl)
library(XML)
library(jsonlite)
library(akima)
library(zoo)
library(lubridate)


#######  
scrapeExpiries <- function(symbol){
  baseUrl <- "https://finance.yahoo.com/quote/"
  
  url <- paste(baseUrl, symbol, "/options?p=", symbol, sep="")
  # pull the html from the given url
  htmlString <- getURL(url)
  # parse the html string 
  htmlParsed <- htmlParse(htmlString, asText = TRUE) 
  # locate the expiries using XPath
  value.expiries <- xpathSApply(htmlParsed, "//div[@class = 'Fl(start) Pend(18px) option-contract-control drop-down-selector']//option", xmlGetAttr, "value")
  
  return(value.expiries)
}
  
#######
getOptions <- function(symbol, date){
  baseUrl <- "https://query2.finance.yahoo.com/v7/finance/options/"
  
  url <- paste(baseUrl, symbol, "?date=", date, sep="")
  json <- getURL(url)
  
  # convert json into R object
  json <- fromJSON(json)
  
  # traverse the list to get back the calls and puts information
  jsonCalls <- json[[1]][["result"]]$options[[1]]$calls[[1]]
  jsonPuts <- json[[1]][["result"]]$options[[1]]$puts[[1]]
  
  # return the types of options separately
  lst <- list(jsonCalls, jsonPuts)
  
  return(lst)
}
  
#######
# function to extract the necessary information from the calls data frame
formatCalls <- function(calls){
  concatCalls <- list()
  
  for(callExp in calls){
    relevantInfo <- cbind(callExp$strike, callExp$expiration, callExp$lastPrice)
    concatCalls <- rbind(concatCalls, relevantInfo)
  }
  
  callsData <- as.data.frame(concatCalls)
  names(callsData) <- c("Strike", "Days to Expiration", "Price")
  
  return(callsData)
}
  
#######
# function to extract the necessary information from the puts data frame
formatPuts <- function(puts){
  concatPuts <- list()
  
  for(putExp in puts){
    relevantInfo <- cbind(putExp$strike, putExp$expiration, putExp$lastPrice)
    concatPuts <- rbind(concatPuts, relevantInfo)
  }
  
  putsData <- as.data.frame(concatPuts)
  names(putsData) <- c("Strike", "Days to Expiration", "Price")
  
  return(putsData)
}

#####
# function to handle interpolation for surface data
interpolater <- function(options){
  strikes <- as.numeric(options[,1])
  daysToExp <- as.numeric(options[,2])
  prices <- as.numeric(options[,3])
  
  optionsInterp <- interp(strikes, daysToExp, prices, extrap=TRUE)
  interpMatrix <- interp2xyz(optionsInterp)
  
  # approximate NA values in object
  interpNAApprox <- na.approx(interpMatrix)
  # make remaining uninterpolated values 0
  interpNAApprox[,3][is.na(interpNAApprox[,3])] <- 0
  
  x <- as.matrix(interpNAApprox[,1])
  y <- as.matrix(interpNAApprox[,2])
  z <- as.matrix(interpNAApprox[,3])
  optionsMatrix <- cbind(x, y, z)
  
  # return separate matricies for each variable
  return(optionsMatrix)
}
  
####### 
# *Invoked to run script
initializer <- function(){
  
  # getting the dates from the html of the website and turning them into strings
  dates <- scrapeExpiries(symbol)
  calls <- list()
  puts <- list()
  
  # Iterating through the expiries to get their corresponding options
  for(expiry in dates){
    optionsInstance <- getOptions(symbol, expiry)
  
    calls <- append(calls, optionsInstance[1])
    puts <- append(puts, optionsInstance[2])
  }
  
  # assigning the formatted result to the appropriate variable
  calls <- formatCalls(calls)
  puts <- formatPuts(puts)

  ####
  # Time to expiry using time of expiry in Epoch minus the current time
  timeToExpEpoch <- function(timeOfExp){
    timeOfExp <- as.numeric(timeOfExp)
    timeNow <- as.numeric(Sys.time())
    (timeOfExp - timeNow) / (24*60*60)
  }
  
  # convert the Epoch time to expiry into Days
  calls["Days to Expiration"] <- floor(sapply(calls["Days to Expiration"], timeToExpEpoch))
 
  # convert the Epoch time to expiry into Days
  puts["Days to Expiration"] <- floor(sapply(puts["Days to Expiration"], timeToExpEpoch))
  
  # Interpolate the data from the calls
  interpolatedCallsList <- interpolater(calls)
  colnames(interpolatedCallsList) <- c("Strike", "Days to Expiry", "Price")
  
  # Interpolate the data from the puts
  interpolatedPutsList <- interpolater(puts)
  colnames(interpolatedPutsList) <- c("Strike", "Days to Expiry", "Price")
  
  write.csv(interpolatedCallsList, file="calls.csv", row.names = FALSE)
  write.csv(interpolatedPutsList, file="puts.csv", row.names = FALSE)
  
  return(interpolatedCallsList)
}
  
##### Run initializer
initializer()





