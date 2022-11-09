#' plot_act_bar
#'
#' @description Creates a bar chart of past ACT use and predicted cases
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
plot_act_bar <- function(plot_data){

  #to debug
  # plot_data <- readRDS("data/for-app/stockout-plot-data.rds")

  ggplot(plot_data, aes(x = year, group = as.factor(year))) +
    geom_col(aes(y = med, fill = fill_label), position = position_stack()) +
    geom_errorbar(aes(ymin = lowCI, ymax = uppCI), width = 0) +
    facet_wrap(~CSB, scales = "free") +
    scale_fill_manual(values = c("darkred", "gray50", "black"), name = "") +
    theme(legend.position = "bottom") +
    xlab("") +
    ylab("Nombre de Cas") +
    ggtitle("Cas Reçu et Traité aux CSB2 (Jan - March)")


}
