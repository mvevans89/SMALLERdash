#' cases_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_cases_map_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    column(3,
           #month selection
                  #month selection
                  airDatepickerInput(ns("monthSelect"),
                                     label = "Choisir un mois:",
                                     value = "2020-12-01",
                                     minDate = "2017-01-01",
                                     maxDate = "2021-03-01",
                                     view = "months",
                                     minView = "months",
                                     dateFormat = "yyyy-MM",
                                     language = "fr")),
           column(3,
                  #CSB selection
                  selectInput(ns("csb"), label = "Zoom à un CSB:",
                             choices = c("Tous CSBs", "Ambalavolo", 'Ambiabe', "Ambodiara Sud",
                                         "Ambodimanga Nord", "Ambohimanga du Sud", "Ambohimiera",
                                         "Ampasinambo", "Analamarina", 'Analampasina', "Androrangavola",
                                         "Antaretra", "Antsindra", "Fasintsara", 'Ifanadiana', "Kelilalina",
                                         "Mahasoa", "Maroharatra", "Maromanana", "Marotoko", 'Ranomafana',
                                         "Tsaratanana"),
                             selected = "Tous CSBs")),
           #button to load
           column(1,
                  actionButton(ns("go_map"), "Allez!")),
           #map in second row
           column(12,
                  leafletOutput(ns("map")))

  ) #end fluidRow
}

#' cases_map Server Functions
#'
#' @noRd
#' @import dplyr
#' @import leaflet
#' @import sf
#' @importFrom scales rescale
mod_cases_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #load data
    full.data <- readRDS("data/for-app/cases-csb-sp.rds")
    zoom.coords <- readRDS("data/for-app/csb-cent.rds")

    #create base map
    data.subset <- filter(full.data, date == as.Date("2020-12-01")) %>%
      #create radius varible(rescaling median value to pixel size)
      mutate(radius = scales::rescale(median, to = c(10,40)))

    output$map <- renderLeaflet(plot_case_map(map_data = data.subset))

    #remake the map with the button is clicked
    #filters to a different month and zooms
    observeEvent(input$go_map,{
      # cat(file=stderr(), "clicked allez") #to debug
      #subset to a new month
      data.subset <- filter(full.data,
                            date == as.Date(input$monthSelect, origin = as.Date("1970-01-01"))) %>%
        #update highlighting
        mutate(highlight_wt = case_when(
          CSB %in% toupper(input$csb) ~ TRUE,
          TRUE ~ FALSE
        )) %>%
        #create radius variable (rescale to pixel values)
        mutate(radius = scales::rescale(median, to = c(10,40)))

      #new map
      output$map <- renderLeaflet(plot_case_map(map_data = data.subset))

      #zoom if needed
      if(!(input$csb == "Tous CSBs")){
        # cat(file=stderr(), print(input$csb)) #debug

        this.zoom <- zoom.coords %>%
          filter(CSB %in% toupper(input$csb))

        # cat(file=stderr(), print(this.zoom$lat))
        #update map with zoom
        leafletProxy("map")%>%
          setView(lat = this.zoom$lat, lng = this.zoom$lon, zoom = 12)
      }
    })

  })
}

#test function
case_map_demo <- function(){
  #source functions for plotting
  source("R/leaflet-legend-decreasing.R")
  source("R/utils_cases_map.R")
  #declare packages
  library(shiny)
  library(shinyWidgets)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(ggplot2)
  library(leaflet)
  library(sf)

  ui <- fluidPage(
    mod_cases_map_ui("map_case1")
  )

  server <- function(input, output, session){

    mod_cases_map_server("map_case1")
  }
  shinyApp(ui, server)
}
