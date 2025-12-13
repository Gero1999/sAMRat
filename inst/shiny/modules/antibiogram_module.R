# Module: Antibiogram UI and Server
#
# Provides `antibiogram_ui(id)` and `antibiogram_server(amr_obj, id)`.
# The server expects `amr_obj` to be a reactive that returns the object
# created by `create_amr_obj()` (i.e., a list with at least element
# `$data`). The module uses `amr_obj$data` as the fixed dataset input and
# exposes widgets for common `antibiogram()` formatting arguments.

antibiogram_ui <- function(id) {
  ns <- NS(id)

  tagList(
    sidebarLayout(
      sidebarPanel(
        uiOutput(ns("antimicrobials_ui")),
        selectInput(ns("mo_transform"), "Microorganism transform:",
                    choices = c("shortname", "name", "gramstain", "none"),
                    selected = "shortname"),
        selectInput(ns("ab_transform"), "Antimicrobial transform:",
                    choices = c("name", "atc", "none"), selected = "name"),
        selectInput(ns("syndromic_group"), "Syndromic group (column):",
                    choices = c("None"), selected = "None"),
        checkboxInput(ns("only_all_tested"), "Require all antimicrobials tested (combination)", value = FALSE),
        checkboxInput(ns("combine_SI"), "Combine S and I as susceptible", value = TRUE),
        numericInput(ns("digits"), "Digits (rounding)", value = 0, min = 0, step = 1),
        # More descriptive choices for formatting_type (labels show number and a short description)
        selectInput(
          ns("formatting_type"), "Formatting type:",
          choices = c(
            "1 — coverage" = "1",
            "2 — susceptible count" = "2",
            "3 — tested count" = "3",
            "4 — susceptible/tested" = "4",
            "5 — coverage (tested)" = "5",
            "6 — coverage% (tested)" = "6",
            "7 — coverage (N=tested)" = "7",
            "8 — coverage% (N=tested)" = "8",
            "9 — coverage (sus/tested)" = "9",
            "10 — coverage% (sus/tested)" = "10",
            "11 — coverage (N=sus/tested)" = "11",
            "12 — coverage% (N=sus/tested)" = "12",
            "13 — coverage (CI)" = "13",
            "14 — coverage% (CI%) [default for WISCA]" = "14",
            "15 — coverage (CI, tested)" = "15",
            "16 — coverage% (CI%, tested)" = "16",
            "17 — coverage (CI, N=tested)" = "17",
            "18 — coverage% (CI%, N=tested) [default]" = "18",
            "19 — coverage (CI, sus/tested)" = "19",
            "20 — coverage% (CI%, sus/tested)" = "20",
            "21 — coverage (CI, N=sus/tested)" = "21",
            "22 — coverage% (CI%, N=sus/tested)" = "22"
          ),
          selected = as.character(getOption("AMR_antibiogram_formatting_type", 18))
        ),
        textInput(ns("sep"), "Combination separator:", value = " + "),
        checkboxInput(ns("sort_columns"), "Sort antimicrobial columns", value = TRUE),
        checkboxInput(ns("wisca"), "Use WISCA (Bayesian) model", value = FALSE),
        conditionalPanel(condition = paste0("input['", ns("wisca"), "'] == true"),
                         numericInput(ns("simulations"), "WISCA simulations:", value = 1000, min = 100, step = 100),
                         numericInput(ns("conf_interval"), "Confidence interval:", value = 0.95, min = 0.5, max = 0.9999, step = 0.01),
                         selectInput(ns("interval_side"), "Interval side:", choices = c("two-tailed", "left", "right"), selected = "two-tailed")
        ),
        actionButton(ns("generate"), "Generate antibiogram", class = "btn btn-primary w-100"),
        br(), br(),
        helpText("Data source: fixed to amr_obj$data. Language and AMR package options are taken from global options/modal settings.")
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Output", DT::DTOutput(ns("antibiogram_print"))),
          tabPanel("Plot", plotOutput(ns("antibiogram_plot"), height = "550px")),
          tabPanel("Numeric (long)", DT::DTOutput(ns("antibiogram_table")))
        )
      )
    )
  )
}


antibiogram_server <- function(amr_obj, id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # reactive that returns the dataset (or NULL)
    data_r <- reactive({
      ao <- NULL
      try({ ao <- amr_obj() }, silent = TRUE)
      if (is.null(ao)) return(NULL)
      if (is.list(ao) && !is.null(ao$data)) return(ao$data)
      # if amr_obj itself is the data.frame
      if (is.data.frame(ao)) return(ao)
      NULL
    })

    # Detect SIR-like columns and update antimicrobials UI
    observeEvent(data_r(), {
      df <- data_r()
      if (is.null(df)) {
        output$antimicrobials_ui <- renderUI({
          helpText("No data available (amr_obj$data is NULL).")
        })
        return()
      }

      sir_cols <- names(df)[sapply(df, function(col) {
        # prefer AMR::is.sir_eligible if available, fall back to checking values
        ok <- FALSE
        try({ ok <- AMR::is.sir_eligible(col) }, silent = TRUE)
        if (isFALSE(ok)) {
          # quick heuristic: column contains at least one of 'S','I','R'
          ok <- any(na.omit(as.character(col)) %in% c("S","I","R","s","i","r"))
        }
        ok
      })]

      output$antimicrobials_ui <- renderUI({
        ns <- session$ns
  selectizeInput(ns("antimicrobials"), "Antimicrobials (select or type combinations, e.g. TZP+TOB):",
           choices = sir_cols,
           selected = if (length(sir_cols) > 0) sir_cols[seq_len(min(4, length(sir_cols)))] else NULL,
           multiple = TRUE,
           options = list(create = TRUE, placeholder = 'Pick or type names/codes'))
      })

      # syndromic group choices: columns or None
      grp_choices <- c("None", names(df))
      updateSelectInput(session, "syndromic_group", choices = grp_choices, selected = "None")
    }, ignoreNULL = FALSE)

    # Generate antibiogram on button press
    observeEvent(input$generate, {
      df <- data_r()
      if (is.null(df)) {
        showNotification("No data available to generate antibiogram.", type = "error")
        return()
      }

      antimicrobials <- input$antimicrobials
      if (is.null(antimicrobials) || length(antimicrobials) == 0) {
        showNotification("Please select at least one antimicrobial (or type combinations).", type = "warning")
        return()
      }

      # Build args; keep language and AMR package options fixed (from global options)
      args <- list(
        x = df,
        antimicrobials = antimicrobials,
        mo_transform = if (input$mo_transform == "none") NULL else input$mo_transform,
        ab_transform = if (input$ab_transform == "none") NULL else input$ab_transform,
        syndromic_group = if (is.null(input$syndromic_group) || input$syndromic_group == "None") NULL else input$syndromic_group,
        only_all_tested = isTRUE(input$only_all_tested),
        digits = input$digits,
        formatting_type = as.numeric(input$formatting_type),
        col_mo = NULL, # use default detection
        language = AMR::get_AMR_locale(), # fixed to default
        minimum = 30,
        combine_SI = isTRUE(input$combine_SI),
        sep = input$sep,
        sort_columns = isTRUE(input$sort_columns),
        wisca = isTRUE(input$wisca)
      )

      if (isTRUE(input$wisca)) {
        args$simulations <- input$simulations
        args$conf_interval <- input$conf_interval
        args$interval_side <- input$interval_side
      }

      # Run antibiogram() defensively
      ab_res <- tryCatch({
        do.call(AMR::antibiogram, args)
      }, error = function(e) {
        showNotification(paste("antibiogram() error:", e$message), type = "error", duration = NULL)
        return(structure(list(error = TRUE, message = e$message), class = "ab_error"))
      })

      # Render the antibiogram result as a data.frame table when possible
      output$antibiogram_print <- DT::renderDT({
        if (is.null(ab_res)) return(NULL)
        if (inherits(ab_res, "ab_error")) return(NULL)

        # Try coercing the result to a data.frame. Many antibiogram objects
        # can be coerced via as.data.frame(); otherwise fall back to the
        # 'long_numeric' attribute if present.
        df_out <- tryCatch({ as.data.frame(ab_res) }, error = function(e) NULL)
        if (is.null(df_out)) {
          long <- attr(ab_res, "long_numeric")
          if (!is.null(long) && is.data.frame(long)) df_out <- long
        }

        if (is.null(df_out)) {
          showNotification("Could not coerce antibiogram result to a table. See the Numeric (long) tab for raw numbers.", type = "warning")
          return(NULL)
        }

        DT::datatable(df_out, options = list(pageLength = 10))
      })

      # Plot if possible
      output$antibiogram_plot <- renderPlot({
        if (is.null(ab_res) || inherits(ab_res, "ab_error")) return()
        if (requireNamespace("ggplot2", quietly = TRUE)) {
          try({
            ggplot2::autoplot(ab_res)
          }, silent = TRUE)
        }
      })

      # Show numeric long attribute if present
      output$antibiogram_table <- DT::renderDT({
        if (is.null(ab_res) || inherits(ab_res, "ab_error")) return(NULL)
        long <- attr(ab_res, "long_numeric")
        if (!is.null(long) && is.data.frame(long)) {
          DT::datatable(long, options = list(pageLength = 10))
        } else {
          # fallback: try to coerce to data.frame
          df_out <- tryCatch({ as.data.frame(ab_res) }, error = function(e) NULL)
          if (!is.null(df_out)) DT::datatable(df_out, options = list(pageLength = 10)) else NULL
        }
      })
    })

    # Expose a small reactive for testing/others if needed
    return(list(
      last_result = reactive({
        # capture the last generated result by reading the print output
        # Not a perfect store; consumers should rely on UI outputs
        NULL
      })
    ))
  })
}
