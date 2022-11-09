#' plot_cases_time
#'
#' @description Function to plot the CSB cases time series
#'
#' @param historical whether to plot historical data, default = T
#' @param current.month current month that predictions go from
#' @param csbSelect which CSB to plot, defaults to district-wide
#' @import ggplot2 lubridate stringr
#' @return ggplot of time series
#'
#' @noRd
plot_cases_time <- function(historical = T,
                            current.month = as.Date("2020-12-01"),
                            csbSelect = "Tous CSBs"){

  #packages

  #to debug
    # csbSelect = "Ifanadiana"
    # historical = T

  #data subset and plot title
  if(csbSelect == "Tous CSBs"){
    p.title <- "Cas Predits pour Tout Ifanadiana"
    #load data
    plot_data <- readRDS("data/for-app/cases-district.rds")
  } else {
    p.title <- paste("Cas Predits à",
                     stringr::str_to_title(csbSelect), "CSB")
    plot_data <- readRDS("data/for-app/cases-csb.rds") %>%
      filter(CSB %in% toupper(csbSelect))
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
  pred.label.y <- max(plot_data$uppCI, na.rm = T) * 1.1

  #return plot
  ggplot(data = plot_data, aes(x = month_lab)) +
    geom_ribbon(aes(ymin = lowCI, ymax = uppCI, group = season),
                alpha = 0.3, fill = "black") +
    # geom_point(aes(y = inc_true, color = season)) +
    geom_line(aes(y = median, color = season, group = season, size = season)) +
    geom_vline(aes(xintercept = month.abb[month(current.month)]), color = "gray50") +
    geom_label(data = data.frame(), aes(x = 10.5, y = pred.label.y, label = "Prédiction"), hjust = 0.5) +
    xlab("Mois") +
    ylab("Total des cas de paludisme au CSBs") +
    scale_color_manual(values = color.scale, name = "Saison") +
    scale_size_manual(values = size, name = "Saison") +
    coord_cartesian(xlim = c(1.5,11.5), clip = "on") +
    theme(legend.position = "bottom") +
    labs(title = p.title,
         subtitle = "Predit Jan - Mar 2021")

  # cat(file=stderr(), "ran plotting function") #debug in Shiny
}
