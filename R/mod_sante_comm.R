#' sante_comm UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom tidyr separate
#' @importFrom DT dataTableOutput formatStyle formatRound

mod_sante_comm_ui <- function(id){
  ns <- NS(id)

  fluidRow(
    #inputs
    column(3,
           #commune selection
           selectInput(ns("commune"), label = "Choisir un commune:",
                       choices = c("Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                                   "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                                   "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                                   "Marotoko", 'Ranomafana', "Tsaratanana"),
                       selected = "Ranomafana")),
    column(3,
           #fokontany selection (this gets updated based on commune)
           selectInput(ns("fokontany"), label = "Choisir un fokontany:",
                       choices = c("Ranomafana"), selected = "Ranomafana")),
    column(2,
           selectInput(ns("indicator"), "Choisir un  indicateur:",
                       choices = c("Cas" = "case", "Incidence" = "inc"), selected = "incidence")
    ),
    #button to load
    column(1,
           actionButton(ns("go_map"), "Allez!")
           ),

    # fluid Row for time series plot
      column(12,
           plotlyOutput(ns("plot"))
    ),
    #fluid row for table of data
    column(12,
           dataTableOutput(ns("dt_table"))
           ),
    column(5,),
    column(3,
           shiny::downloadButton(
             outputId = ns("download_button"),
             label = "Télécharger le tableau."
           )
    )
  )#fluid row
}


#function to add the plotly plot and datatable
mod_sante_comm_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    #starting plot and table
    output$plot <- renderPlotly(timeseries_comm(communeSelect = "Ranomafana",
                                                fktSelect = "Ranomafana",
                                                indicator = "case"))

    table_data <- readRDS("data/for-app/inc-fokontany.rds") |>
      tidyr::separate(comm_fkt, into = c("commune", "fokontany"), sep = "_") |>
      filter(commune %in% toupper("Ranomafana") & fokontany %in% toupper("Ranomafana")) |>
      select(commune, fokontany, date, starts_with("case")) %>%
      #format to have it make more sense
      select(-ends_with("true")) |>
      mutate_at(vars(starts_with("case")), ~floor(.))
    colnames(table_data) <- c("Commune", "Fokontany", "Date", "Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale")

    #output table
    output$dt_table <- DT::renderDataTable(create_dt(table_data))
    output$download_button <- shiny::downloadHandler(
      filename = paste0("Ranomafana-Ranomafana-inc.csv"),
      content = function(file_path)
      {
        write_file(file_path = file_path, data = table_data)
      }
    )

    observeEvent(input$go_map,{
    #must save these outside the render call or it is reactive
      this_commune <- input$commune
      this_fokontany <- input$fokontany
      this_indicator <- input$indicator
    output$plot <- renderPlotly(timeseries_comm(communeSelect = this_commune,
                                                  fktSelect = this_fokontany,
                                                  indicator = this_indicator))



    table_data <- readRDS("data/for-app/inc-fokontany.rds") |>
      tidyr::separate(comm_fkt, into = c("commune", "fokontany"), sep = "_") |>
      filter(commune %in% toupper(this_commune) & fokontany %in% toupper(this_fokontany)) |>
      select(commune, fokontany, date, starts_with(this_indicator)) %>%
      #format to have it make more sense
      select(-ends_with("true")) |>
      mutate_at(vars(starts_with(this_indicator)), ~floor(.))
    colnames(table_data) <- c("Commune", "Fokontany", "Date", "Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale")


    #output table
    output$dt_table <- DT::renderDataTable(create_dt(table_data))
    #data for download
    output$download_button <- shiny::downloadHandler(
      filename = paste0(this_commune, "-", this_fokontany, "-", this_indicator, ".csv"),
      content = function(file_path)
      {
        write_file(file_path = file_path, data = table_data)
      }
    )
    }) #end observeEvent

  }) #end moduleServer
}

#test function
mod_sante_demo <- function(){
  #source function for plotting
  source("R/utils_sante_comm.R")
  #source mod for selecting fokontany
  source("R/mod_fktselect.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(plotly)
  library(DT)

  ui <- fluidPage(
    mod_sante_comm_ui("inc1")
  )

  server <- function(input, output, session){

    mod_fktselect_server("inc1")
    mod_sante_comm_server("inc1")
  }
  shinyApp(ui, server)
}

