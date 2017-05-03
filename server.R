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
  
  observeEvent(input$go, {
    options <- initializer(input$company)
    data <- as.data.frame(options)
    # print(input$company)
    output$graph <- renderVis3D(vis3D(data))
    
  })
  
  
})
