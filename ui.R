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
library(vis3D)
library(rsconnect)

# Define UI for application
shinyUI(fluidPage(
  theme = shinytheme("cosmo"),
  
  # Application title
  titlePanel("Options Analyzer"),
  hr(),
  
  sidebarLayout(
    sidebarPanel(
      tags$head(tags$style("#graph{height:80vh !important;}")),
      textInput("company", "Enter Company Symbol", placeholder = "e.g. AAPL"),
      actionButton("calls", "Get Calls!"),
      actionButton("puts", "Get Puts!"),
      br(),
      br(),
      textOutput("error")
    ),
    
    mainPanel(vis3DOutput("graph"))
  )
))
