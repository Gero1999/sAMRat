# Module for help modal
# Exports modal_help_ui(id) (placeholder) and modal_help_server(id, trigger)

library(shiny)

modal_help_ui <- function(id) {
  tagList()
}

# trigger: reactive that fires when help button is pressed (e.g. reactive(input$help_button))
modal_help_server <- function(id, trigger) {
  moduleServer(id, function(input, output, session) {
    observeEvent(trigger(), {
      showModal(
        modalDialog(
          title = "Help",
          tabsetPanel(
            tabPanel("About",
              h4("About this app"),
              p("This Shiny application is a lightweight front-end for conducting Antimicrobial Resistance (AMR) analyses using the AMR package for R."),
              p("Use the Data tab to upload and prepare a dataset, map columns to recognized roles (microorganism, antibiotic results, MICs, disk zones, dates, subject IDs), and convert columns using AMR helpers such as as.mo(), as.sir(), as.mic(), and as.disk()."),
              p("The app is intended as a convenience wrapper for common AMR workflows: data cleaning, first-isolate filtering, and basic summary statistics. For full documentation and advanced functions, see the AMR package vignette and website.")
            ),
            tabPanel("Data",
              h4("About the Data tab"),
              p("The Data tab lets you:"),
              tags$ul(
                tags$li("Upload a dataset (CSV or Excel)."),
                tags$li("Automatically detect and/or manually map columns to: microorganism (mo), antibiotic SIR results, MIC values, disk diffusion measurements, collection date, and subject ID."),
                tags$li("Preview the dataset and run the 'Do Mapping' action which converts columns into AMR-friendly classes (e.g. as.mo, as.sir, as.mic)."),
                tags$li("Optionally filter to first isolates and export the prepared object for downstream analyses.")
              ),
              p("If something doesn't map correctly, adjust the column selections and press 'Do Mapping' again. Mapped object becomes available to other modules for analysis and plotting.")
            )
          ),
          footer = modalButton("Close"),
          easyClose = TRUE,
          size = "l"
        )
      )
    }, ignoreInit = TRUE)

    # module returns nothing explicit; kept for future extension
    invisible(NULL)
  })
}
