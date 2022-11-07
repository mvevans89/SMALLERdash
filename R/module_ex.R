#experimenting with modules for plotting
library(shiny)
library(ggplot2)
library(dplyr)

#define a plotting function
plot_fx <- function(plot_setosa = T){
  plot_data <- iris
  if(!plot_setosa){
    plot_data <- dplyr::filter(plot_data, Species != "setosa")
  }
  ggplot(plot_data, aes(x = Sepal.Length, y = Petal.Width)) +
    geom_point(aes(color = Species))
}

mod_plot_ui <- function(id){
  ns <- NS(id)
  tagList(
    checkboxInput(ns("setosa"), "Plot setosa?", value = T),
    plotOutput(ns("plot"))
  )
}

mod_plot_server <- function(id) {
  moduleServer(id, function(input, output, session){
    output$plot <- renderPlot({plot_fx(plot_setosa = input$setosa)})
  })
}

#test function
test_mod <- function(){
  data(iris)
  ui <- fluidPage(mod_plot_ui("test1"))
  server <- function(input, output, session){
    mod_plot_server("test1")
  }
  shinyApp(ui, server)
}
