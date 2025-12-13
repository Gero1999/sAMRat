# R Shiny app for AMR analysis
library(shiny)
library(AMR)
library(dplyr)
library(ggplot2)
library(bslib)
library(DT)

# source all module files
source("modules/tab_data.R")
source("modules/modal_settings.R")
source("modules/modal_help.R")
source("modules/tab_results.R")

source("modules/antibiogram_module.R")

ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "flatly"),
  tags$head(
    tags$style(HTML(
      ".app-header{display:flex;align-items:center;justify-content:space-between;padding:12px 8px;border-bottom:1px solid #e6e6e6;background:#fff;}
       .app-header-left{display:flex;align-items:center;gap:12px}
       .app-header-right{display:flex;align-items:center;gap:8px}
       .app-title{margin:0;font-size:1.25rem;font-weight:600}
       @media (max-width:600px){.app-header{flex-direction:column;align-items:flex-start}.app-header-right{margin-top:8px}}"
    ))
  ),
  div(class = "app-header",
      div(class = "app-header-left",
          tags$img(src = "images/logo.png", alt = "AMR logo", height = "50", style = "width:auto;height:50px;"),
          div(
            h1(class = "app-title", "sAMRat"),
            p(style = "margin:0;font-size:0.9rem;color:#666;", "shiny AMR analysis toolkit")
          )
      ),
      div(class = "app-header-right",
          actionButton("help_button", "", icon = icon("circle-info"), class = "btn btn-outline-secondary"),
          actionButton("settings_button", "", icon = icon("cog"), class = "btn btn-outline-secondary")
      )
  ),
  # Main tabset: place the data module as the primary tab
  tabsetPanel(
    tab_data_ui("data"),
    tab_results_ui("results")
  )
)

server <- function(input, output, session) {
  # call data tab module
  amr_obj <- tab_data_server("data")
  # call results module - pass the reactive returned by data module
  tab_results_server("results", amr_obj = amr_obj)

  # Modal messages activated by action buttons
  settings <- modal_settings_server("settings", trigger = reactive(input$settings_button))
  modal_help_server("help", trigger = reactive(input$help_button))
}

shinyApp(ui, server)
