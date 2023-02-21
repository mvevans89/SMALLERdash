#' timeseries_commune
#'
#' @description A utils function
#'
#' @param communeSelect names of csbs selected in UI
#' @param indicator whcih indicator to plot. options = "inc", "case",
#'
#' @example timeseries_commune("Ambiabe", "case")
#'
#' @return a plotly object
#'
#' @noRd

timeseries_commune <- function(communeSelect,
                           indicator){
  #to debug
  # indicator = "inc
  # csbSelect = "Ambiabe"

  plot_data <- readRDS("data/for-app/inc-commune.rds") %>%
    filter(commune %in% toupper(communeSelect))
  p.title <- stringr::str_to_title(communeSelect)

  if(indicator == "inc"){
    ind_cols <- c("y_med" = "inc_med", "y_lowCI" = "inc_lowCI", "y_uppCI" = "inc_uppCI")
    y_lab <- "Incidence (per 1000)"
    p.title <- paste(p.title, " Commune Incidence")
  } else if (indicator == "case"){
    ind_cols <- c("y_med" = "case_med", "y_lowCI" = "case_lowCI", "y_uppCI" = "case_uppCI")
    y_lab <- "Cas Totals"
    p.title <- paste(p.title, "Commune Cas")
  }
  plot_data <- rename(plot_data, ind_cols)

  #plotly prefers wide data
  plotly_data <- plot_data |>
    select(y_med, season, month_lab) |>
    #round for better labels
    mutate(y_med = round(y_med,2)) |>
    mutate(season = gsub("/", "_", paste("Season", stringr::str_trim(season), sep = "_"))) |>
    tidyr::pivot_wider(names_from = season, values_from = y_med)
  plotly_cis <- plot_data |>
    filter(season == "Present")

  source("R/utils_plotlyTime.R")
  plotly_timeseries(input_data = plotly_data, ci_data = plotly_cis,
                    ylabel = y_lab, ptitle = p.title)
}
