#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source('./yahooOptionsQuote.R')

shinyServer(function(input, output) {
  
  observeEvent(input$options1Button, {
    optionsRunner("AAPL")
    #js$refresh();
    # print("hey")
  })
  
  observeEvent(input$options2Button, {
    #optionsRunner("MSFT")
  })
  
  observeEvent(input$options3Button, {
    # optionsRunner("IBM")
  })
  
})
