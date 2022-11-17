#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny shinydashboard shinydashboardPlus
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    fluidPage(
      dashboardPage(

        skin = "green",

        # HEADER -----------------------------------------
        header = dashboardHeader(title = "SMALLER: Prédire le palu dans le district d'Ifanadiana",
                        titleWidth = 550,
                        tags$li(a(href = "https://sante.gov.mg",
                                  img(src = "www/msanp-logo.jpg",
                                  height = "30px"),
                                style = "padding-top:10px; padding-bottom:10px;"),
                        class = "dropdown"),
                        tags$li(a(href = "https://www.pivotworks.org",
                                  img(src = "www/pivot-logo.png",
                                      height = "30px"),
                                  style = "padding-top:10px; padding-bottom:10px;"),
                                class = "dropdown"),
                        tags$li(a(href = "https://www.ird.fr/",
                                  img(src = "www/ird-logo.png",
                                      height = "30px"),
                                  style = "padding-top:10px; padding-bottom:10px;"),
                                class = "dropdown")),

        # SIDEBAR -------------------------------------
        sidebar = dashboardSidebar(width = 200,
            sidebarMenu(
              menuItem("Home", icon = icon("home"),
                       menuSubItem("L'application", tabName = "home"),
                       menuSubItem("Le modèle", tabName = "model_info")),
              # menuItem("Incidence", tabName = "incidence")
              menuItem("Incidence et Cas", tabName = "inc_head",
                       menuSubItem("Séries Temporels", tabName = "inc_time"),
                       menuSubItem("Cartographie", tabName = "inc_map")),
              menuItem("Cas au CSB", tabname = "case_head",
                       menuSubItem("Séries Temporels", tabName = "case_time"),
                       menuSubItem("Cartographie", tabName = "case_map")),
              menuItem("Ruptures du Stock", tabName = "stock_head",
                       menuSubItem("CSB2", tabName = "stock_csb2"))
              ) # end sidebarMenu
                         ), #end dashboardSidebar

        # BODY -------------------------------------------------
        body = dashboardBody(
          #change background to white
          #eventually do in bslib
          tags$head(tags$style(HTML('
                  .content-wrapper {
                    background-color: #fff;
                  }
                '
          ))),

          tabItems(
            ## home landing page ------------------
            tabItem(tabName = 'home',
                includeMarkdown("inst/app/www/home.md")
                    ),
            tabItem(tabName = "model_info",
                    includeMarkdown("inst/app/www/model-info.md")),
            ## incidence tab ------------------
            tabItem(tabName = 'inc_time',
                    #intro and intructions
                    fluidRow(box(status = "info",
                                 title = "Séries Temporels d'Indicateurs Mensuelle du Paludisme",
                        includeMarkdown("inst/app/www/inc-time.md"),
                        width = 12)),
              #contains the plot of incidence time series
              fluidRow(
                column(12,
                  mod_incidence_time_plotly_ui("inc1")))),#ends incidence tab

            tabItem(tabName = "inc_map",
                    #intro and instruction
                    fluidRow(box(status = "info",
                                 title = "Cartes d'Incidence Mensuelle du Paludisme",
                                 includeMarkdown("inst/app/www/inc-map.md"),
                                 width = 12)),
                    #map of incidence
                    mod_incidence_map_ui("map_inc1")
                    ),
            ## cases tab --------------
            tabItem(tabName = "case_time",
                    #intro and instruction
                    fluidRow(box(status = "info",
                                 title = "Séries Temporels des Cas de Paludisme Prise en Charge aux CSBs",
                                 includeMarkdown("inst/app/www/case-time.md"),
                                 width = 12)),
                    #time series of cases
                    mod_cases_time_plotly_ui("case1")),

            tabItem(tabName =  "case_map",
                    #intro and instruction
                    fluidRow(box(status = "info",
                                 title = "Cartes des Cas de Paludisme Prise en Charge aux CSBs",
                                 includeMarkdown("inst/app/www/case-map-intro.md"),
                                 width = 12)),
                    #selectin and map of cases
                    mod_cases_map_ui("map_case1")),
            ## stockout tab ------------------
            tabItem(tabName = "stock_csb2",
                    #intro and instruction
                    fluidRow(box(status = "info",
                                 title = "Risque du Rupture du Stock aux CSBs",
                                 includeMarkdown("inst/app/www/stock-act-csb2.md"),
                                 width = 12)),
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
