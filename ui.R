#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)

# Define UI for application
shinyUI(fluidPage(theme=shinytheme("cosmo"),
  
  # Application title
    titlePanel("Options Analyzer"),
    tags$head(tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.19.1/vis.js")),
    tags$head(includeScript("./www/calls.js")),
    tags$head(includeScript("./www/puts.js")),
    tags$head(includeScript("./www/surface.js")),
    sidebarLayout(
   
      sidebarPanel(
        selectInput("company", "Choose a company:",
                  choices = c("AAPL", "MSFT", "IBM"), selectize=TRUE)),
    
      mainPanel(
        includeHTML("index.html")
      )
    )
  
  )
)
