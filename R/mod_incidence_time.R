#' incidence_time UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#'

mod_incidence_time_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    #inputs
    column(3,
            #commune selection
            selectInput(ns("commune"), label = "Choisir un commune:",
                        choices = c("District","Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                          "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                          "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                          "Marotoko", 'Ranomafana', "Tsaratanana"),
                        selected = "District")),
    column(3,
           #fokontany selection (this gets updated based on commune)
           selectInput(ns("fokontany"), label = "Choisir un fokontany:",
                          choices = c("Selectionner"), selected = "Selectionner")),
    column(3,
           checkboxInput(ns("historical"), "Afficher historique?", value = T)
  ), #fluidRow
    column(12,
    plotOutput(ns("plot"))
    )
  )#fluid row
}

mod_incidence_time_plotly_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    #inputs
    column(3,
           #commune selection
           selectInput(ns("commune"), label = "Choisir un commune:",
                       choices = c("District","Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                                   "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                                   "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                                   "Marotoko", 'Ranomafana', "Tsaratanana"),
                       selected = "District")),
    column(3,
           #fokontany selection (this gets updated based on commune)
           selectInput(ns("fokontany"), label = "Choisir un fokontany:",
                       choices = c("Selectionner"), selected = "Selectionner"))
    , #fluidRow
    column(12,
           plotlyOutput(ns("plot"))
    )
  )#fluid row
}

mod_incidence_time_plotly_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlotly({plot_inc_time_plotly(communeSelect = input$commune,
                                             fktSelect = input$fokontany)})
  })
}

#' incidence_time Server Functions
#'
#' @noRd
mod_incidence_time_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    output$plot <- renderPlot({plot_inc_time(historical = input$historical,
                                             communeSelect = input$commune,
                                             fktSelect = input$fokontany)})
  })
}

mod_fktselect_server <- function(id){
  moduleServer(id, function(input,output,session){
    ns <- session$ns
    #reactive list of fokontany if fokontany level is chosen
    observe({
      chosen.commune <- input$commune
      if(chosen.commune != "District"){
        fkt.names <- readRDS("data/for-app/fokontany_names_std.rds") %>%
          filter(commune %in% toupper(chosen.commune)) %>%
          pull(fokontany) %>%
          stringr::str_to_title()
      } else {
          fkt.names <- "Selectionner"
        }
    updateSelectInput(session, "fokontany", label = "Choisir un fokontany:",
                      choices = c("Selectionner", fkt.names), selected = "Selectionner")
  }) #end observe
  })
}


#test function
inc_time_demo <- function(){
  #source function for plotting
  source("R/utils_incidence_time.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)

  ui <- fluidPage(
      # mod_incidence_time_ui("inc1")
      mod_incidence_time_plotly_ui("inc1")
  )
  server <- function(input, output, session){

    mod_fktselect_server("inc1")
    mod_incidence_time_server("inc1")
    mod_incidence_time_plotly_server("inc1")
  }
  shinyApp(ui, server)
}
