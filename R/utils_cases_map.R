#' cases_map
#'
#' @description A utils function
#' @param map_data case data that we ant to map
#' @import sf dplyr leaflet
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
plot_case_map <- function(map_data){
  #packages
  # require(sf)
  # require(dplyr)
  # library(leaflet)
  # source("R/leaflet-legend-decreasing.R")

  #data for debugging
  # map_data <- readRDS("data/for-app/cases-csb-sp.rds") %>%
  #   filter(date == as.Date("2020-12-01")) %>%
  #   mutate(radius = scales::rescale(median, to = c(10,40))) %>%
  #   mutate(highlight_wt = (CSB == "RANOMAFANA"))

  #background commune data
  comm.poly <- readRDS("data/ifd_commune_poly.rds") %>%
    st_transform(4326)

  #define color palettes, reverse is for legend
  colorpal <- colorNumeric(
    palette = "YlOrRd",
    domain = map_data$median,
    na.color = NA
  )

  colorpalLegend <- colorNumeric(
    palette = "YlOrRd",
    domain = map_data$median,
    na.color = NA,
    reverse = TRUE
  )

  leaflet(map_data) %>%
    addTiles() %>%
    setView(lat = -21.3, lng = 47.6, zoom = 10) %>%
    addPolygons(data = comm.poly,
                fillOpacity = 0,
                opacity = 1,
                weight  = 1,
                color = "black") %>%
    addCircleMarkers(data = map_data, lng = ~lon, lat = ~lat,
                     fillColor = ~colorpal(median),
                     radius = ~radius,
                     color = "black",
                     stroke = TRUE,
                     weight = ~ifelse(highlight_wt,6,1),
                     fillOpacity = 1,
                     popup = ~popup
                     # label = ~CSB,
                     # labelOptions = labelOptions(noHide = TRUE, direction = "bottom",
                     #                             style = list(
                     #                               "font-size" = "6px"
                     #                             ))
    ) %>%
    addLegend_decreasing("bottomright", pal = colorpal, values = ~median,
                         title = "Cas Paludisme<br>Predit", na.label = "", decreasing = TRUE)
}
