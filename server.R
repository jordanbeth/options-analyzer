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
    output$graph <- renderVis3D(vis3D(calls))
  })
  
  observeEvent(input$puts, {
    options <- initializer(input$company)
    puts <- as.data.frame(options[[2]])
    output$graph <- renderVis3D(vis3D(puts))
    
  })
  
})
