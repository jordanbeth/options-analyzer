#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(devtools)
library(vis3D)
source('./optionsQuoteAnalyzer.R')


shinyServer(function(input, output) {
  observeEvent(input$calls, {
    options <-
      tryCatch(
        initializer(input$company),
        error = function(e) {
          e
        }
      )
    
    if (class(options)[1] == "simpleError") {
      output$error <- renderText("Error! Calls Not Available.")
    } else{
      calls <- as.data.frame(options[[1]])
      graph <- visOptions3D(
        vis3D(calls),
        tooltip = TRUE,
        showShadow = TRUE,
        xLabel = "Strike",
        yLabel = "Days to Expiry",
        zLabel = "Price",
        filterLabel = "Strike"
      )
      output$error <- renderText("")
      output$graph <- renderVis3D(graph)
    }
    
  })
  
  observeEvent(input$puts, {
    options <-
      tryCatch(
        initializer(input$company),
        error = function(e) {
          e
        }
      )
    
    if (class(options)[1] == "simpleError") {
      output$error <- renderText("Error! Puts Not Available.")
    } else{
      puts <- as.data.frame(options[[2]])
      graph <- visOptions3D(
        vis3D(puts),
        tooltip = TRUE,
        showShadow = TRUE,
        xLabel = "Strike",
        yLabel = "Days to Expiry",
        zLabel = "Price"
      )
      output$error <- renderText("")
      output$graph <- renderVis3D(graph)
    }
  })
  
})
