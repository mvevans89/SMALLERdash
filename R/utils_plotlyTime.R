#' Create a plotly plot
#' @description Creates plotly plots of time series
#' @param input_data dataframe to use to plot all data
#' @param ci_data dataframe of CIs for error in predictions
#' @param ylabel label for y-axis of plot
#' @param ptitle label for plot
#'
#' @import plotly
#'
plotly_timeseries <- function(input_data, ci_data, ylabel, ptitle){

  color.scale <- c("#682D63", "#414288", "#5FB49C", "black")
  size <- c(1, 1, 1, 2)

  plot_ly(input_data, showlegend = TRUE) |>
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
    add_ribbons(data = ci_data, x = ~month_lab, ymin = ~y_lowCI, ymax = ~y_uppCI,
                fillcolor = scales::alpha(color.scale[4],0.2), hoverinfo = 'none',
                line = list(color = scales::alpha(color.scale[4],0.2)),
                name = 'Evéntail') |>
    #add vertical line for prediction area
    layout(shapes = list(vline(x = 8))) |>
    layout(hovermode = "x unified",
           yaxis = list(title = ylabel),
           xaxis = list(title = "Mois d'Année"),
           title = ptitle) |>
    #remove buttons on top
    config(modeBarButtonsToRemove = c("zoom2d", "zoomIn2d", "zoomOut2d", "pan2d", 'autoScale2d', "resetScale2d"),
           displaylogo = FALSE)



}

#' Create a vertical line in plotly
#' @description function to create a vertical line in plotly
#' @param x x-intercept of line
#' @param color color of the line
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
