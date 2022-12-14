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

#' plot_cases_time_plotly
#'
#' @description Function to plot the CSB cases time series using plotly
#'
#' @param current.month current month that predictions go from
#' @param csbSelect which CSB to plot, defaults to district-wide
#' @import plotly lubridate stringr
#' @importFrom scales alpha
#' @importFrom tidyr pivot_wider
#'
#' @return ggplot of time series
#'
#' @noRd
plot_cases_time_plotly <- function(
                            current.month = as.Date("2020-12-01"),
                            csbSelect = "Tous CSBs"){

  #packages

  #to debug
  # csbSelect = "Tous CSBs"

  # data subset and plot title
  if(csbSelect == "Tous CSBs"){
    p.title <- "Cas Predits pour tout Ifanadiana"
    #load data
    plot_data <- readRDS("data/for-app/cases-district.rds") %>%
      ungroup()
  } else {
    p.title <- paste("Cas Predits à",
                     stringr::str_to_title(csbSelect), "CSB")
    plot_data <- readRDS("data/for-app/cases-csb.rds") %>%
      filter(CSB %in% toupper(csbSelect))
  }

  #always show all years
  color.scale <- c("#682D63", "#414288", "#5FB49C", "black")

  #function for vertical line in plotly
  vline <- function(x = 0, color = "gray50") {
    list(
      type = "line",
      y0 = 0,
      y1 = 1,
      yref = "paper",
      x0 = x,
      x1 = x,
      line = list(color = color, dash="dot", width = 0.5)
    )
  }

  #create plotly style data (should be done outside in the future)
  plotly_data <- plot_data |>
    select(cases = median, season, month_lab) |>
    #round for better labels
    mutate(cases = round(cases,0)) |>
    mutate(season = gsub("/", "_", paste("Season", stringr::str_trim(season), sep = "_"))) |>
    tidyr::pivot_wider(names_from = season, values_from = cases)
  plotly_cis <- plot_data |>
    filter(season == "Present") |>
    mutate(lowCI = round(lowCI),
           uppCI = round(uppCI))

  #return plot
  plot_ly(plotly_data, showlegend = TRUE) |>
    add_trace(x = ~month_lab, y = ~Season_2017_2018, type = 'scatter', mode = 'lines',
              name = "2017/2018", line = list(color = color.scale[1])) |>
    #add lines for each year
    add_trace(x = ~month_lab, y = ~Season_2018_2019, type = 'scatter', mode = 'lines',
              name = "2018/2019", line = list(color = color.scale[2])) |>
    add_trace(x = ~month_lab, y = ~Season_2019_2020, type = 'scatter', mode = 'lines',
              name = "2019/2020", line = list(color = color.scale[3])) |>
    add_trace(x = ~month_lab, y = ~Season_Present, type = 'scatter', mode = 'lines',
              name = "2020/2021", line = list(color = color.scale[4], width = 4)) |>
    #add error range
    add_ribbons(data = plotly_cis, x = ~month_lab, ymin = ~lowCI, ymax = ~uppCI,
                fillcolor = scales::alpha(color.scale[4],0.2), hoverinfo = 'none',
                line = list(color = scales::alpha(color.scale[4],0.2)),
                name = 'Evéntail') |>
    #add vertical line for prediction area
    layout(shapes = list(vline(x = 8))) |>
    layout(hovermode = "x unified",
           yaxis = list(title = "Total des cas de paludisme au CSBs"),
           xaxis = list(title = "Mois d'Année"),
           title = p.title) |>
    #remove buttons on top
    config(modeBarButtonsToRemove = c("zoom2d", "zoomIn2d", "zoomOut2d", "pan2d", 'autoScale2d', "resetScale2d"),
           displaylogo = FALSE)

  # cat(file=stderr(), "ran plotly function") #debug in Shiny
}
