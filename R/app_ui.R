#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny shinydashboard
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      dashboardPage(

        skin = "green",

        dashboardHeader(title = "Paludisme Prédictions"),

        dashboardSidebar(width = 300,
            sidebarMenu(
              menuItem("Home", tabName = "Home", icon = icon("home")),
              menuItem("Incidence", tabName = "incidence")
            ) # end sidebarMenu
                         ), #end dashboardSidebar
        dashboardBody(

          tabItems(
            tabItem(tabName = 'home',
                    "Landing Page for the App"),
            tabItem(tabName = 'incidence',
              #contains the plot of incidence time series
              mod_incidence_time_ui("inc1"))

          )
        ) #end dashboardBody

    ) #end  dashboardPage
  ) #end fluidPage
  ) #end tagList
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "SMALLERdash"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
