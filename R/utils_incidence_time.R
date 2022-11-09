#functions to create plots of incidence

#they are created from this data
# inc.district <- readRDS("data/for-app/inc-district.rds")
# inc.commune <- readRDS("data/for-app/inc-commune.rds")
# inc.fkt <- readRDS("data/for-app/inc-fokontany.rds")

#' Plot incidence timeseries
#' @param historicalwhether to plot historical data, default = T
#' @param current.month first day of current month, used to draw prediction line
#' @param communeSelect name of commune selected in UI
#' @param fktSelect name of fokontany selected in UI
#' @import ggplot2 lubridate stringr
#' @noRd
plot_inc_time <- function(historical = T,
                          current.month = as.Date("2020-12-01"),
                          communeSelect = "District",
                          fktSelect = "Selectionner"){
  #packages
  require(ggplot2)
  require(stringr)
  require(lubridate)


  #create plot title and dataset subset
  if(communeSelect == "District"){
    p.title <- 'Ifanadiana District Incidence'
    #load data
    plot_data <- readRDS("data/for-app/inc-district.rds")
  } else if(fktSelect == "Selectionner"){
    p.title <- paste(stringr::str_to_title(communeSelect),"Commune Incidence")
    #load data
    plot_data <- readRDS("data/for-app/inc-commune.rds") %>%
      filter(commune %in% toupper(communeSelect))
  } else {
    p.title <- paste0(stringr::str_to_title(communeSelect), ": ",
                      stringr::str_to_title(fktSelect)," Incidence")
    plot_data <- readRDS("data/for-app/inc-fokontany.rds") %>%
      filter(comm_fkt %in% toupper(paste(communeSelect, fktSelect, sep = "_")))
  }

  #limit data to historical & create aesthetics if necessary
  if(historical){
    color.scale <- c("#682D63", "#414288", "#5FB49C", "black")
    size <- c(1, 1, 1, 2)
  } else {
    plot_data <- filter(plot_data, season == "Present")
    color.scale <- "black"
    size <- 1
  }

  #determine placement of label for predictions
  pred.label.y <- max(plot_data$inc_uppCI, na.rm = T) * 1.1

  ggplot(data = plot_data, aes(x = month_lab)) +
    geom_ribbon(aes(ymin = inc_lowCI, ymax = inc_uppCI, group = season),
                alpha = 0.3, fill = "black") +
    # geom_point(aes(y = inc_true, color = season)) +
    geom_line(aes(y = inc_med, color = season, group = season, size = season)) +
    geom_vline(aes(xintercept = month.abb[month(current.month)]), color = "gray50") +
    geom_label(data = data.frame(), aes(x = 10.5, y = pred.label.y, label = "Prédiction"), hjust = 0.5) +
    xlab("Mois") +
    ylab("Incidence (per 1000)") +
    scale_color_manual(values = color.scale, name = "Saison") +
    scale_size_manual(values = size, name = "Saison") +
    coord_cartesian(xlim = c(1.5,11.5), clip = "on") +
    theme(legend.position = "bottom") +
    theme_bw() +
    labs(title = p.title,
         subtitle = "Predit Jan - Mar 2021")

  # cat(file=stderr(), "ran plotting function")
}

