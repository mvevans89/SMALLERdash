#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  #landing page map
  mod_landing_map_server("land_map")
  #community health server
  mod_sante_comm_server("comm1")
  mod_fktselect_server("comm1")

  #commune level server
  mod_sante_primaire_server("commune")

  #stockout barchart module
  mod_stock_act_server("act1")
}


