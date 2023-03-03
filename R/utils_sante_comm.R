#' timeseries_comm
#'
#' @description  Plot incidence timeseries using plotly
#'
#' @param communeSelect name of commune selected in UI
#' @param fktSelect name of fokontany selected in UI
#' @param indicator which indicator to plot. options = "inc", "case"
#'
#' @import plotly lubridate stringr
#' @importFrom scales alpha
#' @importFrom tidyr pivot_wider
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
timeseries_comm <- function(communeSelect,
                              fktSelect,
                              indicator = "inc"){
  # to debug
  # communeSelect = "Ifanadiana"
  # fktSelect = "Ifanadiana
  # indicator = "inc"

  #create plot title and dataset subset
    p.title <- paste0(stringr::str_to_title(communeSelect), ": ",
                      stringr::str_to_title(fktSelect))
    plot_data <- readRDS("data/for-app/inc-fokontany.rds") %>%
      filter(comm_fkt %in% toupper(paste(communeSelect, fktSelect, sep = "_")))

  #select columns for each indicator
  #choose columns to plot depending on indicator
  if(indicator == "inc"){
    ind_cols <- c("y_med" = "inc_med", "y_lowCI" = "inc_lowCI", "y_uppCI" = "inc_uppCI")
    y_lab <- "Incidence (per 1000)"
    p.title <- paste(p.title, "Incidence")
  } else if (indicator == "case"){
    ind_cols <- c("y_med" = "case_med", "y_lowCI" = "case_lowCI", "y_uppCI" = "case_uppCI")
    y_lab <- "Cas Totals"
    p.title <- paste(p.title, "Cas")
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

  source("R/utils_plotlyTime.R") #functions for plotting
  plotly_timeseries(input_data = plotly_data, ci_data = plotly_cis,
                    ylabel = y_lab, ptitle = p.title)

  # cat(file=stderr(), "ran plotly function")
}

#other helper functions
#utility functions
#data table
create_dt <- function(table_df){
  DT::datatable(table_df,
                options = list(paging = TRUE, searching = TRUE),
                rownames = F) |>
    formatStyle(columns = colnames(table_df), fontSize = '75%') |>
    formatRound(columns = c("Estimation Minimale", 'Estimation Moyenne', "Estimation Maximale"), digits = 0)
}

write_file <- function(file_path, data)
{
  data.table::fwrite(x = data, file = file_path)
}
