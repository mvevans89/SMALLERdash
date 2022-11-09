#' casee_time UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_casee_time_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' casee_time Server Functions
#'
#' @noRd 
mod_casee_time_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_casee_time_ui("casee_time_1")
    
## To be copied in the server
# mod_casee_time_server("casee_time_1")
