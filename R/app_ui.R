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
        sidebar = dashboardSidebar(width = 250,
            sidebarMenu(
              menuItem("Palu en Bref", icon = icon("gauge", lib = 'font-awesome'),
                       tabName = "flash_dash"),
              menuItem("Santé\nCommunautaire", icon = icon('people-roof', lib = "font-awesome"),
                       menuSubItem("Taux aux Fokontany", tabName = "comm_time")),
              menuItem("Santé Primaire", icon = icon("hospital", lib = "font-awesome"),
                       menuSubItem("Taux aux Communes", tabName = "commune_time"),
                       menuSubItem("Ruptures du Stock", tabName = "stock_csb2")),
              menuItem("À propos", icon = icon("circle-info", lib = "font-awesome"),
                       menuSubItem("L'application", tabName = "about"),
                       menuSubItem("Le modèle", tabName = "model_info"))
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
            ## landing page with highlights ---------
                tabItem(tabName = "flash_dash",
                        fluidRow(
                          titlePanel("  Projections pour Janvier 2021"),
                          #these will eventually need to update automatically every month
                          valueBox(value = 8000,
                                   subtitle = "cas pour 100k",
                                   color = "purple",
                                   icon = icon("person-rays", lib = "font-awesome"),
                                   width = 3),
                          valueBox(value = 15000,
                                   subtitle = "cas totals prédit",
                                   color = "aqua",
                                   icon = icon("person-burst", lib = "font-awesome"),
                                   width = 3),
                          valueBox(value = "+140%",
                                   subtitle = "comparé à l'année passée",
                                   color = "red",
                                   icon = icon("chart-line", lib = "font-awesome"),
                                   width = 3),
                          valueBox(value = "4 CSB",
                                   subtitle = "au risque du rupture du stock",
                                   color = "teal",
                                   icon = icon("pills", lib = "font-awesome"),
                                   width = 3)
                        ),
                        mod_landing_map_ui("land_map")
                        ), #end landing page tab
            ## community health tab -------------
            tabItem(tabName = "comm_time",
                    #intro and instructions
                    fluidRow(box(status = "info",
                                 title = "Séries Temporels au Niveau Communautaire",
                                 includeMarkdown("inst/app/www/community-time.md"),
                                 width = 12)),
                    #sante communautaire UI
                    mod_sante_comm_ui("comm1")),
            ## commune time series tab -----------
            tabItem(tabName = "commune_time",
                    fluidRow(box(status = "info",
                                 title = "Séries Temporels au Niveau Commune",
                                 includeMarkdown("inst/app/www/commune-time.md"),
                                 width = 12)),
                    mod_sante_primaire_ui("commune")),

            ## stockout tab ------------------
            tabItem(tabName = "stock_csb2",
                    #intro and instruction
                    fluidRow(box(status = "info",
                                 title = "Risque du Rupture du Stock aux CSBs",
                                 includeMarkdown("inst/app/www/stock-act-csb2.md"),
                                 width = 12)),
                    #bar chart of ACTs
                    mod_stock_act_ui("act1")),
            ## about the model page ------------------
            tabItem(tabName = 'about',
                    includeMarkdown("inst/app/www/home.md")
            ),
            tabItem(tabName = "model_info",
                    includeMarkdown("inst/app/www/model-info.md"))
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
