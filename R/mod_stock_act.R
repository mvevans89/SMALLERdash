#' stock_act UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets pickerInput
mod_stock_act_ui <- function(id){
  ns <- NS(id)

  fluidRow(
    column(3,
          pickerInput(ns("csbSelect"), "Selectionner des CSB2:",
                      choices = c('Ambiabe', "Ambohimanga du Sud", "Ambohimiera",
                                  "Ampasinambo", 'Analampasina', "Androrangavola",
                                  "Antaretra", "Antsindra", "Fasintsara", 'Ifanadiana', "Kelilalina",
                                  "Maroharatra", "Marotoko", 'Ranomafana',
                                  "Tsaratanana"), selected = c("Ambiabe"),
                      multiple = TRUE, options = list(`actions-box` = TRUE))),
    #next row
    column(12,
           plotOutput(ns("plot")))
  ) #end fluid row
}

#' stock_act Server Functions
#'
#' @noRd
mod_stock_act_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  data.subset <- reactive({
    #validate so error message makes sense
    validate(
      need(input$csbSelect != "", "Choisir au moins un CSB")
    )
    readRDS("data/for-app/stockout-plot-data.rds") %>%
      dplyr::filter(CSB %in% toupper(input$csbSelect))
  })

  output$plot <- renderPlot(plot_act_bar(plot_data = data.subset()))

  })
}

stock_bar_demo <- function(){
  #source functions
  source("R/utils_stock_act.R")
  #declare packages
  library(shiny)
  library(shinyWidgets)
  library(dplyr)
  library(lubridate)
  library(stringr)

  ui <- fluidPage(
    mod_stock_act_ui("act1")
  )
  server <- function(input, output, session){

    mod_stock_act_server("act1")
  }
  shinyApp(ui, server)
}
