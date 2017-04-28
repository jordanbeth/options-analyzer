library(RCurl)
library(XML)
library(jsonlite)
library(plot3D)
library(akima)
library(zoo)
# wrapper to run everything on command
optionsRunner <- function(symbol="AAPL"){
  
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
  
  #####
  # manually getting options quotes passing a ticker symbol and an Epoch date
  symbol <- symbol 
  may5 <- getOptions(symbol, "1493942400")
  may12 <- getOptions(symbol, "1494547200")
  may19 <- getOptions(symbol, "1495152000")
  may26 <- getOptions(symbol, "1495756800")
  
  #####
  # function to extract the necessary information from the calls data frame
  formatCalls <- function(calls){
    concatCalls <- cbind(calls[[1]]$strike, calls[[1]]$expiration, calls[[1]]$lastPrice)
    callsData <- as.data.frame(concatCalls)
    names(callsData) <- c("Strike", "Days to Expiration", "Price")
    return(callsData)
  }
  
  ####
  # function to extract the necessary information from the puts data frame
  formatPuts <- function(puts){
    puts <- cbind(puts[[2]]$strike, puts[[2]]$expiration, puts[[2]]$lastPrice)
    puts <- as.data.frame(puts)
    names(puts) <- c("Strike", "Days to Expiration", "Price")
    return(puts)
  }
  
  #### 
  may5calls <- formatCalls(may5)
  may5puts <- formatPuts(may5)
  
  may12calls <- formatCalls(may12)
  may12puts <- formatPuts(may12)
  
  may19calls <- formatCalls(may19)
  may19puts <- formatPuts(may19)
  
  may26calls <- formatCalls(may26)
  may26puts <- formatPuts(may26)
  ####
  
  # Time to expiry using time of expiry in Epoch minus the current time
  timeToExpEpoch <- function(timeOfExp){
    timeNow <- as.numeric(Sys.time())
    timeOfExp - timeNow
  }
  
  # bind all of the calls into one data frame
  calls <- rbind(may5calls, may12calls, may19calls, may26calls)
  
  # convert the Epoch time to expiry into Days
  calls["Days to Expiration"] <- floor(sapply(calls["Days to Expiration"], timeToExpEpoch) / (24*60*60))
  
  # bind all of the puts into one data frame
  puts <- rbind(may5puts, may12puts, may19puts, may26puts)
  
  # convert the Epoch time to expiry into Days
  puts["Days to Expiration"] <- floor(sapply(puts["Days to Expiration"], timeToExpEpoch) / (24*60*60))
  
  ####
  calls <- interp(calls[,1], calls[,2], calls[,3])
  interpolatedCalls <- interp2xyz(calls)
  
  x <- as.matrix(interpolatedCalls[,1])
  y <- as.matrix(interpolatedCalls[,2])
  z <- as.matrix(interpolatedCalls[,3])
  
  puts <- interp(puts[,1], puts[,2], puts[,3])
  interpolatedPuts <- interp2xyz(puts)
  
  callsJSON <- toJSON(calls)
  putsJSON <- toJSON(puts)

  ####
  # write(callsJSON, file="calls.js")
  # write(putsJSON, file="puts.js")
  write(callsJSON, file="test.js")
  
  return(calls)
  # write.csv(calls, file = "mayCalls", row.names = FALSE)
  # write.csv(puts, file = "mayPuts", row.names = FALSE)
}
