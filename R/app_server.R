#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  #files to source
  source("R/utils_incidence-timeseries.R")

  #incidence time series modules
  mod_fktselect_server("inc1")
  mod_incidence_time_server("inc1")
}


