#' casee_time UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_cases_time_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    #inputs
    column(3,
           #select CSB
           selectInput(ns("csb"), label = "Choisir un CSB:",
                       choices = c("Tous CSBs", "Ambalavolo", 'Ambiabe', "Ambodiara Sud",
                                   "Ambodimanga Nord", "Ambohimanga du Sud", "Ambohimiera",
                                   "Ampasinambo", "Analamarina", 'Analampasina', "Androrangavola",
                                   "Antaretra", "Antsindra", "Fasintsara", 'Ifanadiana', "Kelilalina",
                                   "Mahasoa", "Maroharatra", "Maromanana", "Marotoko", 'Ranomafana',
                                   "Tsaratanana"),
                       selected = "Tous CSBs")),
    column(3,
           checkboxInput(ns("historical"), "Afficher historique?", value = T)),
    #next row (hopefully)
    #plot output
    column(12,
           plotOutput(ns("plot"))
    )
  )#end fluidRow
}

#' casee_time Server Functions
#'
#' @noRd
mod_cases_time_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlot({plot_cases_time(historical = input$historical,
                                             csbSelect = input$csb)})
  })
}

case_time_demo <- function(){
  #source functions and packages
  source("R/utils_cases_time.R")
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  ui <- fluidPage(
    mod_cases_time_ui("case1")
  )

  server <- function(input, output, session){
    mod_cases_time_server("case1")
  }

  shinyApp(ui, server)
}
