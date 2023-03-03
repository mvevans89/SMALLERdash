#' landing_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom leaflet leafletOutput renderLeaflet
mod_landing_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(12,
             leafletOutput(ns("map"), height="100vh")
      )
    )
  )
}

#' landing_map Server Functions
#'
#' @noRd
#' @import dplyr
#' @import leaflet
#' @import sf
mod_landing_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #create map
    map_data <- readRDS("data/for-app/inc_map_popup.rds") |>
      filter(date == as.Date("2021-01-01"))

    colorpal <- colorNumeric(
      palette = "YlOrRd",
      #set domain to min max of full dataset
      # domain = c(0,550),
      #or just current dataset (then it changes each month)
      domain = map_data$median,
      na.color = NA
    )
    colorpalLegend <- colorNumeric(
      palette = "YlOrRd",
      # domain = c(0,550),
      domain = map_data$median,
      na.color = NA,
      reverse = TRUE
    )

    output$map <- renderLeaflet(
    leaflet(map_data) %>%
      addTiles() %>%
      setView(lat = -21, lng = 47.6, zoom = 10) %>%
      addPolygons(data = map_data,
                  fillColor = ~colorpal(median),
                  color = "black",
                  opacity = 1,
                  weight = 0.5,
                  fillOpacity = 0.8,
                  highlightOptions = highlightOptions(color = "black", bringToFront = TRUE,
                                                      weight = 3),
                  popup = ~popup) %>%
      addLegend_decreasing("bottomright", pal = colorpal, values = ~median,
                           title = "Taux Paludisme<br>Prédit<br>(pour 1000)",
                           na.label = "", decreasing = TRUE)
    )


  })
}

#testing function
map_demo <- function(){
  #source functions
  source("R/leaflet-legend-decreasing.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(leaflet)

  ui <- fluidPage(
    mod_landing_map_ui("test1")
  )

  server <- function(input, output, session){

    mod_landing_map_server("test1")
  }
  shinyApp(ui, server)
}
