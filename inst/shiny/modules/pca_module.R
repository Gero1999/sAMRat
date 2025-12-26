# Module: PCA UI and Server
#
# Provides `pca_ui(id)` and `pca_server(amr_obj, id)`.
# - Uses amr_obj$data (reactive) as fixed dataset.
# - Lets the user choose a grouping column from microorganism metadata
#   (e.g., gram_stain, genus, species, etc.).
# - Computes per-group susceptibility proportions across selected SIR columns
#   and runs PCA on that numeric matrix.

pca_ui <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("group_column"), "Group by (column):",
                    choices = NULL, selected = NULL, multiple = TRUE),
        selectizeInput(ns("ab_cols"), "Antimicrobial SIR columns:",
                       choices = NULL, multiple = TRUE),
        actionButton(ns("run_pca"), "Run PCA", class = "btn btn-primary w-100"),
        br(), br(),
        helpText("PCA uses per-group susceptibility proportions of selected antimicrobials.")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Summary", verbatimTextOutput(ns("pca_summary"))),
          tabPanel("Plot", plotOutput(ns("pca_plot"), height = "550px"))
        )
      )
    )
  )
}


pca_server <- function(amr_obj, id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data <- reactive({
      req(amr_obj())
      data <- amr_obj()$data

      # Merge mo information
      mo_info <- amr_obj()$mo
      mo_col <- amr_obj()$mo$columns$mo
      data <- merge(data, mo_info[["traits"]], by.x = mo_col, by.y = "mo", all.x = TRUE)
      data <- merge(data, cbind(mo_info[["taxonomy"]]), by.x = mo_col, by.y = "mo", all.x = TRUE)
      data
    })

    # Using the data information, update the choices for group_column and ab_cols
    observeEvent(data(), {
        mo_grp_cols <- setdiff(names(data()), names(amr_obj()$data))
        updateSelectInput(session, "group_column",
                          choices = mo_grp_cols,
                          selected = if (length(mo_grp_cols) > 0) mo_grp_cols[1] else NULL)
        sir_cols <- amr_obj()$ab$columns$sir
        updateSelectizeInput(session, "ab_cols",
                             choices = sir_cols,
                             selected = if (length(sir_cols) > 0) sir_cols else NULL)
    })


    pca_result <- reactive({
      data() %>%
      group_by(!!!syms(input$group_column)) %>%
      summarize_if(is.sir, resistance) %>%
      select(any_of(input$ab_cols)) %>%
      pca()
    })

    output$pca_summary <- renderPrint({
      req(pca_result())
      summary(pca_result())
    })

    output$pca_plot <- renderPlot({
      req(pca_result())
      ggplot_pca(pca_result(), label_points = input$label_points)
    })

  })
}
