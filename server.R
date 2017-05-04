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
    options <- initializer(input$company)
    calls <- as.data.frame(options[[1]])
    graph <- visOptions3D(vis3D(calls), 
                          tooltip = TRUE, 
                          showShadow = TRUE, 
                          xLabel = "Strike", 
                          yLabel = "Days to Expiry", 
                          zLabel = "Price",
                          filterLabel ="Strike"
                         )
    
    output$graph <- renderVis3D(graph)
  })
  
  observeEvent(input$puts, {
    options <- initializer(input$company)
    puts <- as.data.frame(options[[2]])
    graph <- visOptions3D(vis3D(puts),
                          tooltip = TRUE,
                          showShadow = TRUE,
                          xLabel = "Strike", 
                          yLabel = "Days to Expiry", 
                          zLabel = "Price"
                          )
    
    output$graph <- renderVis3D(graph)
  })
  
})
