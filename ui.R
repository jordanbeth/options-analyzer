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
library(shinyjs)
library(V8)

jscode <- "shinyjs.refresh = function() { history.go(0); }"

# Define UI for application
shinyUI(fluidPage(theme=shinytheme("cosmo"),
    useShinyjs(),
    extendShinyjs(text = jscode),
  # Application title
    titlePanel("Options Analyzer"),
    tags$head(tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.19.1/vis.js")),
    tags$head(includeScript("./www/surface.js")),
    tags$head(includeScript("./calls.js")),
    tags$head(includeScript("./puts.js")),
  
    sidebarLayout(
   
      sidebarPanel(
        actionButton("options1Button", "AAPL"),
        br(),br(),
        actionButton("options2Button", "MSFT"),
        br(),br(),
        actionButton("options3Button", "IBM")
      ),
    
      mainPanel(
        includeHTML("index.html")
      )
    )
  )
)
