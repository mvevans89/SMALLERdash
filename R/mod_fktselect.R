#' module for creating list of fokontany to select from
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import dplyr

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
