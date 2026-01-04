# Module: MDR tab for AMR Shiny app
# Provides `mdr_ui(id)` and `mdr_server(id, amr_obj)`

#' UI for MDR tab
#' @param id module id
#' @return UI element (tabPanel)
mdr_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("guideline"), "Guideline", choices = c(
          "CMI 2012", "Magiorakos et al. 2012", "EUCAST 2023", "EUCAST 2022", "EUCAST 2021", "EUCAST 2020", "EUCAST 2019", "EUCAST 2018", "EUCAST 2017", "EUCAST 2016", "EUCAST 2015", "EUCAST 2014", "EUCAST 2013", "EUCAST 2012", "EUCAST 2011", "EUCAST 2010", "EUCAST 2009", "EUCAST 2008", "EUCAST 2007", "EUCAST 2006", "EUCAST 2005", "EUCAST 2004", "EUCAST 2003", "EUCAST 2002", "EUCAST 2001", "EUCAST 2000"
        ), selected = "CMI 2012"),
        sliderInput(ns("pct_required_classes"), "% Required Classes", min = 0, max = 1, value = 0.5, step = 0.05),
        checkboxInput(ns("combine_SI"), "Combine S and I", value = TRUE),
        checkboxInput(ns("only_sir_columns"), "Only SIR columns", value = TRUE),
        actionButton(ns("run_mdr"), "Run MDR Analysis", icon = icon("play"))
      ),
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Summary",
            h4("MDR/PDR/XDR Summary"),
            tableOutput(ns("mdr_summary"))
          ),
          tabPanel(
            "Isolate Results",
            h4("Isolate MDR Results"),
            DT::DTOutput(ns("mdr_table"))
          )
        )
      )
    )
  )
}

#' Server logic for MDR tab
#' @param id module id
#' @param amr_obj reactive returning the AMR object
mdr_server <- function(id, amr_obj) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    mdr_result <- reactiveVal(NULL)

    observeEvent(input$run_mdr, {
      ao <- amr_obj()
      if (is.null(ao) || is.null(ao$data)) {
        showNotification("No mapped data available. Please run 'Do Mapping' in the Data tab first.", type = "error")
        return()
      }
      df <- ao$data
      # Try to auto-detect mo column
      mo_col <- if (!is.null(ao$mo) && !is.null(ao$mo$naming)) {
        intersect(names(df), c("mo", "MO", "microorganism", "organism"))[1]
      } else {
        NULL
      }
      # Run mdro()
      res <- tryCatch(
        {
          df %>%
            mutate(
              MDRO = AMR::mdro(
                pct_required_classes = input$pct_required_classes,
                combine_SI = input$combine_SI,
                only_sir_columns = input$only_sir_columns,
                verbose = FALSE
              )
            )
        },
        error = function(e) {
          showNotification(paste("MDR analysis error:", e$message), type = "error")
          return(NULL)
        }
      )
      if (!is.null(res)) {
        mdr_result(res)
      }
    })

    # Summary table: count of MDR, XDR, PDR, non-MDR, etc.
    output$mdr_summary <- renderTable(
      {
        res <- mdr_result()
        if (is.null(res)) {
          return(NULL)
        }
        tbl <- table(res[["MDRO"]], useNA = "ifany")
        as.data.frame(tbl, responseName = "Count")
      },
      striped = TRUE,
      bordered = TRUE,
      hover = TRUE
    )

    # Data table: show isolates with MDR status, color by status
    output$mdr_table <- DT::renderDT({
      res <- mdr_result()
      if (is.null(res)) {
        return(NULL)
      }
      # Color rows by MDR status
      status_colors <- c(
        "Negative" = "#e0e0e0",
        "Multi-drug-resistant (MDR)" = "#ffe082",
        "Extensively drug-resistant (XDR)" = "#444343",
        "Pandrug-resistant (PDR)" = "#d32f2f"
      )
      DT::datatable(res, options = list(pageLength = 10)) %>%
        DT::formatStyle(
          "MDRO",
          target = "row",
          backgroundColor = DT::styleEqual(
            names(status_colors),
            unname(status_colors)
          )
        )
    })
  })
}
