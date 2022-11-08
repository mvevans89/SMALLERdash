#' plot_inc_map
#'
#' @description Function to create a leaflet plot of incidence
#' @param map_data incidence data we want to map
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd

plot_inc_map <- function(map_data){
  #packages
  # require(sf)
  # require(ggplot2)
  # require(dplyr)
  # library(leaflet)
  # source("R/leaflet-legend-decreasing.R")

  # fkt.poly <- readRDS(("data/ifd_fokontany_poly.rds")) %>%
  #   #reproject to WGS84
  #   st_transform(4326) %>%
  #   select(comm_fkt)
  #
  # #in function for now just to make sure it works, but will do in server-mod or even beforehand and save
  # map_data <- readRDS("data/for-app/inc_map_popup.rds") %>%
  #   filter(date == as.Date("2020-12-01")) %>%
  #   mutate(highlight = ifelse(comm_fkt == "IFANADIANA_IFANADIANA", "darkred","#4d4d4d")) %>%
  #   mutate(highlight_wt = ifelse(comm_fkt == "IFANADIANA_IFANADIANA", 3,1))


  #identify zoom coordinates (probably do in the server side)
  # zoom.coords <- readRDS("data/for-app/fkt-cent.rds") %>%
  #   filter(commune %in% toupper(communeSelect), fokontany %in% toupper(fktSelect))

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
                         title = "Taux Paludisme<br>Prédit<br>(per 1000)", na.label = "", decreasing = TRUE)

}
