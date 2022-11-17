#' incidence_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets airDatepickerInput
#' @importFrom leaflet leafletOutput renderLeaflet
#' @importFrom DT dataTableOutput
mod_incidence_map_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    #inputs
    column(3,
           #month selection
           airDatepickerInput(ns("monthSelect"),
                              label = "Date:",
                              value = "2020-12-01",
                              minDate = "2017-01-01",
                              maxDate = "2021-03-01",
                              view = "months",
                              minView = "months",
                              dateFormat = "yyyy-MM",
                              language = "fr")),
    column(3,
           #commune selection
           selectInput(ns("commune"), label = "Choisir un commune:",
                       choices = c("Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                                   "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                                   "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                                   "Marotoko", 'Ranomafana', "Tsaratanana"),
                       selected = "Ifanadiana")),
    column(3,
           #fokontany selection (this gets updated based on commune)
           selectInput(ns("fokontany"), label = "Choisir un fokontany:",
                       choices = c("Selectionner un commune"), selected = "Selectionner un commune")),
    column(2,
           selectInput(ns("indicator"), "Choisir un  indicateur:",
                       choices = c("Cas" = "cases", "Incidence" = "incidence"), selected = "incidence")),
    column(1,
           actionButton(ns("go_map"), "Allez!")),
    column(6,
           leafletOutput(ns("map"))),
    column(6,
           dataTableOutput(ns("dt_table")))

  )# end fluid row
}

#' incidence_map Server Functions
#'
#' @noRd
#'
#' @import dplyr
#' @import leaflet
#' @import sf
#' @import DT
mod_incidence_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    #load data
    full.data <- readRDS("data/for-app/inc_map_popup.rds") %>%
      mutate(highlight = factor("normal"))
    zoom.coords <- readRDS("data/for-app/fkt-cent.rds")

    #base map
    data.subset <- filter(full.data, date == as.Date("2020-12-01")) %>%
      mutate(highlight = "#4d4d4d") %>%
      mutate(highlight_wt = 2)
    output$map <- renderLeaflet(plot_inc_map(map_data = data.subset, indicator = "incidence"))

    #base table
    table.data.base <- readRDS("data/for-app/case_map_popup.rds") %>%
      st_drop_geometry() %>%
      #select columns to include
      select(commune, fokontany, date, incidence = inc_med, cases = case_med) %>%
      mutate(incidence = round(incidence,0))
    table.subset <- table.data.base %>%
      #filter to selected fokontany
      filter(commune %in% c("IFANADIANA") & fokontany %in% toupper("IFANADIANA")) %>%
      #filter to date range (year surrounding chosen date)
      filter(date %in% c(seq(as.Date("2020-12-01"), length.out = 6, by = "-1 months"),
                         seq(as.Date("2020-12-01"), length.out = 6, by = "+1 months")))
    #create datatable object here becuase it is easier
    #use a function we can call elsewhere
    create_dt <- function(table_df){
      DT::datatable(table_df,
                   options = list(paging = FALSE, searching = FALSE),
                   rownames = F) %>%
        formatStyle(columns = colnames(table_df), fontSize = '75%')
    }
    dt_table <- create_dt(table.subset)

    output$dt_table <-DT::renderDataTable(dt_table)


    #remake the map when the button is clicked
    observeEvent(input$go_map, {
      # cat(file=stderr(), "clicked allez") #to debug
      #choose cases or incidence
      if(input$indicator == "incidence"){
        new.data <- readRDS("data/for-app/inc_map_popup.rds") %>%
        mutate(highlight = factor("normal"))
      } else if (input$indicator == "cases"){
        new.data <- readRDS("data/for-app/case_map_popup.rds") %>%
          mutate(highlight = factor("normal"))
      }
      #subset to a new month
      data.subset <- filter(new.data,
                            date == as.Date(input$monthSelect, origin = as.Date("1970-01-01"))) %>%
        #highlight the selected commune/fokontany
        mutate(highlight = case_when(
          commune %in% toupper(input$commune) & fokontany %in% toupper(input$fokontany) ~ "black",
          TRUE ~ "#4d4d4d"
        )) %>%
        mutate(highlight_wt = case_when(
          commune %in% toupper(input$commune) & fokontany %in% toupper(input$fokontany) ~ 5,
          TRUE ~ 2
        ))
      #define outside function so it only changes when button is clicked
      this.ind <- input$indicator
      output$map <- renderLeaflet(plot_inc_map(map_data = data.subset, indicator = this.ind))

      #identify coordinates to zoom to
      this.zoom <- zoom.coords %>%
        filter(commune %in% toupper(input$commune), fokontany %in% toupper(input$fokontany))
      #update map with zoom
      leafletProxy("map")%>%
        setView(lat = this.zoom$lat, lng = this.zoom$lon, zoom = 11)

      #create table
      table.data <- table.data.base %>%
        #filter to selected fokontany
        filter(commune %in% toupper(input$commune) & fokontany %in% toupper(input$fokontany)) %>%
        #filter to date range (year surrounding chosen date)
        filter(date %in% c(seq(as.Date(input$monthSelect, origin = as.Date("1970-01-01")), length.out = 6, by = "-1 months"),
                           seq(as.Date(input$monthSelect, origin = as.Date("1970-01-01")), length.out = 6, by = "+1 months")))

      #output table
      output$dt_table <- DT::renderDataTable(create_dt(table.data))

    })
  })
}

#' updates the list of fokontany to choose from
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
inc_map_demo <- function(){
  #source function for plotting
  source("R/utils_incidence_map.R")
  source("R/leaflet-legend-decreasing.R")
  #declare packages
  #to add packages to the package use usethis::use_package
  library(shiny)
  library(shinyWidgets)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(ggplot2)
  library(leaflet)
  library(sf)
  library(DT)


  ui <- fluidPage(
    mod_incidence_map_ui("map_inc1")
  )

  server <- function(input, output, session){

    mod_fktselect_server("map_inc1")
    mod_incidence_map_server("map_inc1")
  }
  shinyApp(ui, server)
}
