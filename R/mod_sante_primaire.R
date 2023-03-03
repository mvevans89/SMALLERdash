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
mod_sante_primaire_ui <- function(id){
  ns <- NS(id)

  fluidRow(
    #inputs
    column(4,
           #select commune
           selectInput(ns("commune"), label = "Choisir un commune:",
                       choices = c("Ambiabe", "Ambohimanga du Sud", "Ambohimiera",
                                   "Ampasinambo", "Analampasina", "Androrangavola",
                                   "Antaretra", "Antsindra", "Fasintsara", "Ifanadiana",
                                   "Kelilalina", "Maroharatra", "Marotoko", "Ranomafana",
                                   "Tsaratanana"),
                       selected = "Ranomafana")
           ),
    column(4,
           selectInput(ns("indicator"), "Choisir un  indicateur:",
                       choices = c("Cas" = "case", "Incidence" = "inc"), selected = "Incidence")
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
    ),
    column(5,), #this helps center download button
    column(3,
           shiny::downloadButton(
             outputId = ns("download_button"),
             label = "Télécharger le tableau."
           )
    )
  )
}


#' sante_phc Server Functions
#'
#' @noRd
mod_sante_primaire_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #starting plot and table
    output$plot <- renderPlotly(timeseries_commune(communeSelect = "Ranomafana",
                                                   indicator = "inc"))
    table_data <- readRDS("data/for-app/inc-commune.rds") |>
      filter(commune %in% toupper("Ranomafana")) |>
      select(commune, date, starts_with("inc")) |>
      select(-ends_with("true")) |>
      mutate_at(vars(starts_with("inc")), ~floor(.))
    colnames(table_data) <- c("Commune", "Date", "Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale")
    #output table
    output$dt_table <- DT::renderDataTable(create_dt(table_data))
    output$download_button <- shiny::downloadHandler(
      filename = paste0("Ranomafana-inc.csv"),
      content = function(file_path)
      {
        write_file(file_path = file_path, data = table_data)
      }
    )


    observeEvent(input$go_map, {
      this_commune <- input$commune
      this_indicator <- input$indicator

      #plotly plot
      output$plot <- renderPlotly(timeseries_commune(communeSelect = this_commune,
                                                     indicator = this_indicator))

      # data table object
      table_data <- readRDS("data/for-app/inc-commune.rds") |>
        filter(commune %in% toupper(this_commune)) |>
        select(commune, date, starts_with(this_indicator)) |>
        select(-ends_with("true")) |>
        mutate_at(vars(starts_with(this_indicator)), ~floor(.))
      colnames(table_data) <- c("Commune", "Date", "Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale")

      #output table
      output$dt_table <- DT::renderDataTable(create_dt(table_data))

      #data for download
      output$download_button <- shiny::downloadHandler(
        filename = paste0(this_commune, "_", this_indicator, ".csv"),
        content = function(file_path)
        {
          write_file(file_path = file_path, data = table_data)
        }
      )

    })

  })
}

#test function
mod_demo <- function(){
  #source function for plotting
  source("R/utils_sante_primaire.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(plotly)
  library(DT)

  ui <- fluidPage(
    mod_sante_primaire_ui("test1")
  )

  server <- function(input, output, session){

    mod_sante_primaire_server("test1")
  }
  shinyApp(ui, server)
}
