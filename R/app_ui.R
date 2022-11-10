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

        dashboardHeader(title = "SMALLER: Prédire le palu dans le district d'Ifanadiana",
                        titleWidth = 600),

        dashboardSidebar(width = 200,
            sidebarMenu(
              menuItem("Home", tabName = "home", icon = icon("home")),
              # menuItem("Incidence", tabName = "incidence")
              menuItem("Incidence", tabName = "inc_head",
                       menuSubItem("Séries Temporels", tabName = "incidence"),
                       menuSubItem("Cartographie", tabName = "inc_map")),
              menuItem("Cas au CSB", tabname = "case_head",
                       menuSubItem("Séries Temporels", tabName = "case_time"),
                       menuSubItem("Cartographie", tabName = "case_map")),
              menuItem("Ruptures de Stock", tabName = "stock_head",
                       menuSubItem("CSB2", tabName = "stock_csb2"))
            ) # end sidebarMenu
                         ), #end dashboardSidebar
        dashboardBody(

          tabItems(
            #home landing page
            tabItem(tabName = 'home',
                h1("Bienvenue!")
                    ),
            #incidence tab
            tabItem(tabName = 'incidence',
              #contains the plot of incidence time series
              mod_incidence_time_plotly_ui("inc1")), #ends incidence tab

            tabItem(tabName = "inc_map",
                    #map of incidence
                    mod_incidence_map_ui("map_inc1")
                    ),

            tabItem(tabName = "case_time",
                    #time series of cases
                    mod_cases_time_ui("case1")),

            tabItem(tabName =  "case_map",
                    #selectin and map of cases
                    mod_cases_map_ui("map_case1")),

            tabItem(tabName = "stock_csb2",
                    #bar chart of ACTs
                    mod_stock_act_ui("act1"))

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
