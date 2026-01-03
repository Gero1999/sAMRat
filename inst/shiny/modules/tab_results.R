# Module: Results tab for AMR Shiny app
# Provides `tab_results_ui(id)` and `tab_results_server(id)`

#' UI for Results tab
#' @param id module id
#' @return UI element (tabPanel)
tab_results_ui <- function(id) {
  ns <- NS(id)
  tabPanel("Results",
    tabsetPanel(
      tabPanel("Full dataset",
        br(),
        DT::DTOutput(ns("full_table"))
      ),
      tabPanel("Antibiograms",
        br(),
        antibiogram_ui(ns("antibiogram")),
        p("Antibiograms coming soon")
      ),
      tabPanel("PCA",
        br(),
        pca_ui(ns("pca"))
      ),
      tabPanel("MDR",
        br(),
        mdr_ui(ns("mdr"))
      )
    )
  )
}

#' Server logic for Results tab
#' @param id module id
tab_results_server <- function(id, amr_obj) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Full dataset table
    output$full_table <- DT::renderDT({
      ao <- amr_obj()
      if (is.null(ao) || is.null(ao$data)) return(NULL)
      DT::datatable(ao$data, options = list(pageLength = 10))
    })

    # Render antibiogram module using the reactive amr_obj (pass the reactive)
    antibiogram_server(amr_obj = amr_obj, id = "antibiogram")

    # Render PCA module
    pca_server(amr_obj = amr_obj, id = "pca")

    # Render MDR module
    mdr_server(id = "mdr", amr_obj = amr_obj)
  })
}
