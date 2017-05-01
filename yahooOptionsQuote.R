library(RCurl)
library(XML)
library(jsonlite)
library(akima)
library(zoo)
library(lubridate)

# wrapper to run everything on command
optionsRunner <- function(symbol="AAPL"){

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
  
  ####### 
  # *Invoked on call so that the function can take related action
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
      timeNow <- as.numeric(Sys.time())
      (timeOfExp - timeNow) / (24*60*60)
    }
    print(calls)
    # convert the Epoch time to expiry into Days
    calls["Days to Expiration"] <- floor(sapply(calls["Days to Expiration"], function(x){timeToExpEpoch(as.numeric(x))}))
    
    # convert the Epoch time to expiry into Days
    calls["Days to Expiration"] <- floor(sapply(calls["Days to Expiration"], timeToExpEpoch) / (24*60*60))
    
    return(calls)
  
  }
  
  ##### Invoked on function call
  initializer()
}









  ####
  #calls <- interp(calls[,1], calls[,2], calls[,3], xo=seq(20, 215, 5), yo=seq(3, 20, 1), extrap=TRUE)
  #interpolatedCalls <- interp2xyz(calls)
  
  # approximate NA values in object
  # interpolatedCallsNAApprox <- na.approx(interpolatedCalls)
  # interpolatedCallsNAApprox[,3][is.na(interpolatedCallsNAApprox[,3])] <- 0
  
  #x <- as.matrix(interpolatedCallsNAApprox[,1])
  #y <- as.matrix(interpolatedCallsNAApprox[,2])
  #z <- as.matrix(interpolatedCallsNAApprox[,3])
  
  # convert NA to 0 for graphing
  #z[is.na(z)] <- 0
  
  #puts <- interp(puts[,1], puts[,2], puts[,3])
  #interpolatedPuts <- interp2xyz(puts)
  
  #callsJSON <- toJSON(calls)
  #putsJSON <- toJSON(puts)

  ####
  # write(callsJSON, file="calls.js")
  # write(putsJSON, file="puts.js")
  # write(callsJSON, file="test.js"))
  # write.csv(interpolatedCallsNAApprox, file = "mayCalls", row.names = FALSE)
  # write.csv(puts, file = "mayPuts", row.names = FALSE)
  #return(interpolatedCallsNAApprox)

 