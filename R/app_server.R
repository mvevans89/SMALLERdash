#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  #incidence time series modules
  mod_fktselect_server("inc1")
  mod_incidence_time_plotly_server("inc1")

  #incidence mapping module
  mod_fktselect_server("map_inc1")
  mod_incidence_map_server("map_inc1")

  #CSB case time series module
  mod_cases_time_server("case1")

  #CSB cases mapping module
  mod_cases_map_server("map_case1")

  #stockout barchart module
  mod_stock_act_server("act1")
}


