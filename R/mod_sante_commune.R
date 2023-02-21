#' sante_commune UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom DT dataTableOutput formatStyle formatRound
#'
mod_sante_commune_ui <- function(id){
  ns <- NS(id)

  fluidRow(
    #inputs
    column(4,
           #select commune
           selectInput(ns("commune"), label = "Choisir un commune:",
                       choices = c("Selectionner", "Ambiabe", "Ambohimanga du Sud", "Ambohimiera",
                                   "Ampasinambo", "Analampasina", "Androrangavola",
                                   "Antaretra", "Antsindra", "Fasintsara", "Ifanadiana",
                                   "Kelilalina", "Maroharatra", "Marotoko", "Ranomafana",
                                   "Tsaratanana"),
                       selected = "Selectionner")
           ),
    column(4,
           selectInput(ns("indicator"), "Choisir un  indicateur:",
                       choices = c("Cas" = "case", "Incidence" = "inc"), selected = "incidence")
    ),
    #button to load
    column(2,
           actionButton(ns("go_map"), "Allez!")
    ),

    # fluid Row for time series plot
    column(12,
           plotlyOutput(ns("plot"))
    ),
    #fluid row for table of data
    column(12,
           dataTableOutput(ns("dt_table"))
    )
  )
}

#' sante_phc Server Functions
#'
#' @noRd
mod_sante_commune_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$go_map, {
      this_commune <- input$commune
      this_indicator <- input$indicator

      #plotly plot
      output$plot <- renderPlotly(timeseries_commune(communeSelect = this_commune,
                                                     indicator = this_indicator))

      # data table object
      #function to make it niclye formatted
      create_dt <- function(table_df){
        DT::datatable(table_df,
                      options = list(paging = TRUE, searching = TRUE),
                      rownames = F) |>
          formatStyle(columns = colnames(table_df), fontSize = '75%') |>
          formatRound(columns = c("Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale"), digits = 0)
      }

      table_data <- readRDS("data/for-app/inc-commune.rds") |>
        filter(commune %in% toupper(this_commune)) |>
        select(commune, date, starts_with(this_indicator)) |>
        select(-ends_with("true"))
      colnames(table_data) <- c("Commune", "Date", "Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale")

      #output table
      output$dt_table <- DT::renderDataTable(create_dt(table_data))

    })

  })
}

#test function
mod_demo <- function(){
  #source function for plotting
  source("R/utils_sante_phc.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(plotly)
  library(DT)

  ui <- fluidPage(
    mod_sante_commune_ui("test1")
  )

  server <- function(input, output, session){

    mod_sante_commune_server("test1")
  }
  shinyApp(ui, server)
}
