# Module: Data tab for AMR Shiny app
# Provides `tab_data_ui(id)` and `tab_data_server(id)`

#' UI for Data tab
#' @param id module id
#' @return UI element (tabPanel)
tab_data_ui <- function(id) {
  ns <- NS(id)
  tabPanel("Data",
    sidebarLayout(
      sidebarPanel(
        fileInput(ns("file"), "Upload dataset", accept = c(".csv", ".xlsx")),
        uiOutput(ns("column_mapping_ui")),
        checkboxInput(ns("filter_first_isolate"), "Filter first_isolate", value = FALSE),
        actionButton(ns("do_mapping"), "Do Mapping")
      ),
      mainPanel(
        DTOutput(ns("data_preview")),
        verbatimTextOutput(ns("analysis_output"))
      )
    )
  )
}

#' Server logic for Data tab
#' @param id module id
tab_data_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Helper: auto-detect columns
    auto_detect_columns <- function(df) {
      cols <- names(df)

      # 1) SIR columns: unique values R, I, S (any of these present)
      sir_cols <- cols[sapply(df, function(x) {
        is_sir_eligible(x)
      })]
      # 2) MIC columns: numeric and colname == as.character(as.ab(colname))
      mic_cols <- cols[sapply(cols, function(col) {
        is.numeric(df[[col]]) && tryCatch({as.character(as.ab(col)) == col}, error=function(e) FALSE)
      })]
      # 3) Disk columns: placeholder (no automatic detection implemented)
      disk_cols <- character(0)
      # 4) Date columns: class is Date or POSIXct
      date_cols <- cols[sapply(df, function(x) inherits(x, c("Date", "POSIXct")))]
      # 5) Subject columns: name matches subject, subjid, usubjid (case-insensitive)
      subject_pattern <- "^(subject|subjid|usubjid|patient).*$"
      subject_cols <- cols[grepl(subject_pattern, tolower(cols))]
      # 6) Microorganism column
      mo_pattern <- "^(mo|microorganism|microbe|bacteria|organism).*$"
      mo_cols <- cols[grepl(mo_pattern, tolower(cols))]
      list(
        sir_cols = sir_cols,
        mic_cols = mic_cols,
        disk_cols = disk_cols,
        date_col = if (length(date_cols) > 0) date_cols[1] else NULL,
        subject_col = if (length(subject_cols) > 0) subject_cols[1] else NULL,
        mo_col = if (length(mo_cols) > 0) mo_cols[1] else NULL
      )
    }

    # Reactive value for uploaded data
    data <- reactive({
      # Provide a default dummy dataset if no file uploaded
      if (is.null(input$file)) return(AMR::example_isolates_unclean)
      ext <- tools::file_ext(input$file$name)
      # Allow the user to upload CSV or Excel files
      if (ext == "csv") {
        read_csv(input$file$datapath)
      } else if (ext == "xlsx") {
        readxl::read_excel(input$file$datapath)
      } else {
        showNotification("Unsupported file type", type = "error")
        NULL
      }
    })

    # UI for column mapping (namespaced outputs/inputs)
    output$column_mapping_ui <- renderUI({
      req(data())
      cols <- names(data())
      detected <- auto_detect_columns(data())
      tagList(
        selectInput(session$ns("mo_col"), "Microorganism column (mo)", choices = cols, selected = if(!is.null(detected$mo_col)) detected$mo_col else NULL),
        selectizeInput(session$ns("sir_col"), "SIR column(s) (ab_sir)", choices = cols, multiple = TRUE, selected = detected$sir_cols),
        selectizeInput(session$ns("mic_col"), "MIC column(s) (ab_mic)", choices = cols, multiple = TRUE, selected = if(length(detected$mic_cols)>0) detected$mic_cols else NULL),
        selectizeInput(session$ns("disk_col"), "Disk column(s) (ab_disk)", choices = cols, multiple = TRUE, selected = if(length(detected$disk_cols)>0) detected$disk_cols else NULL),
        selectInput(session$ns("date_col"), "Date column", choices = c("Optionally add the collection date" = "", cols), selected = if(!is.null(detected$date_col)) detected$date_col else NULL),
        selectInput(session$ns("subject_col"), "Subject column", choices = cols, selected = if(!is.null(detected$subject_col)) detected$subject_col else NULL),
        selectInput(session$ns("other_col"), "Other column", c("Other columns you may like to use for grouping" = "", cols), selected = "")
      )
    })

    # Preview uploaded data
    output$data_preview <- renderDT({
      req(data())
      datatable(data(), options = list(pageLength = 5))
    })

    amr_obj <- reactiveVal(NULL)

    # Do Mapping button logic (delegates to create_amr_obj)
    observeEvent(input$do_mapping, {
      req(data())
      df <- data()

      # prepare parameters
      mo_col <- if (!is.null(input$mo_col)) input$mo_col else NULL
      sir_cols <- if (!is.null(input$sir_col)) input$sir_col else NULL
      mic_cols <- if (!is.null(input$mic_col)) input$mic_col else NULL
      disk_cols <- if (!is.null(input$disk_col)) input$disk_col else NULL
      date_col <- if (!is.null(input$date_col)) input$date_col else NULL
      subject_col <- if (!is.null(input$subject_col)) input$subject_col else NULL

      # call shared function (defined in inst/shiny/functions/create_amr_obj.R)
      amr_obj <- tryCatch({
        create_amr_obj(
          df = df,
          mo_col = mo_col,
          sir_cols = sir_cols,
          mic_cols = mic_cols,
          disk_cols = disk_cols,
          date_col = date_col,
          subject_col = subject_col,
          filter_first_isolate = input$filter_first_isolate
        )
      }, error = function(e) {
        showNotification(paste("Mapping error:", e$message), type = "error")
        return(NULL)
      })

      amr_obj(amr_obj)

      if (is.null(amr_obj)) return()

      # Show summary of amr_obj
      result <- tryCatch({
        capture.output({
          cat("amr_obj created with following structure:\n")
          print(str(amr_obj))
          cat("\nSummary of columns:\n")
          print(summary(amr_obj))
        })
      }, error = function(e) {
        paste("Error:", e$message)
      })
      output$analysis_output <- renderText({
        paste(result, collapse = "\n")
      })
    })

    # Return a reactive to let the main app (or other modules) access the mapped object if needed
    return(amr_obj)
  })
}
