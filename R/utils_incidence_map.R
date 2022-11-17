#' plot_inc_map
#'
#' @description Function to create a leaflet plot of incidence
#' @param map_data incidence data we want to map
#' @param indicator which indicator to plot (cases, incidence)
#' @importFrom dplyr rename
#' @import leaflet sf
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

plot_inc_map <- function(map_data, indicator = "incidence"){
  #packages
  # require(sf)
  # require(ggplot2)
  # require(dplyr)
  # library(leaflet)
  # source("R/leaflet-legend-decreasing.R")

  #to debug
  # map_data <- readRDS("data/for-app/case_map_popup.rds") %>%
  #   filter(date == as.Date("2020-12-01")) %>%
  #   mutate(highlight = factor("normal")) %>%
  #   mutate(highlight_wt = 2)
  # indicator = "cases"

  #legend title if indicator is incidence
  legend.title <- "Taux Paludisme<br>Prédit<br>(per 1000)"
  #rename based on indicator
  if(indicator == "cases"){
    map_data <- dplyr::rename(map_data, median = case_med)
    legend.title <- "Nombre de<br>Cas Totals"
  }

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


  leaflet(map_data) %>%
    addTiles() %>%
    setView(lat = -21.3, lng = 47.6, zoom = 10) %>%
    addPolygons(data = map_data, color = ~highlight, weight = ~highlight_wt,
                fillColor = ~colorpal(median),
                opacity = 1,
                fillOpacity = 0.8,
                highlightOptions = highlightOptions(color = "black", bringToFront = TRUE,
                                                    weight = 3),
                popup = ~popup) %>%
    addLegend_decreasing("bottomright", pal = colorpal, values = ~median,
                         title = legend.title, na.label = "", decreasing = TRUE)

}
