# Module for app settings modal

# Server for settings module
# trigger: a reactive that signals when to open the modal (e.g. reactive(input$settings_button))
# Returns: list(general_settings = reactive({ list(language = <code>) }))
modal_settings_server <- function(id, trigger) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # reactiveVal to store settings
    general_settings_rv <- reactiveVal(list(language = AMR::get_AMR_locale()))

    # language choices
    lang_choices <- c(
      "English" = "en", "Arabic" = "ar", "Bengali" = "bn", "Chinese" = "zh",
      "Czech" = "cs", "Danish" = "da", "Dutch" = "nl", "Finnish" = "fi",
      "French" = "fr", "German" = "de", "Greek" = "el", "Hindi" = "hi",
      "Indonesian" = "id", "Italian" = "it", "Japanese" = "ja", "Korean" = "ko",
      "Norwegian" = "no", "Polish" = "pl", "Portuguese" = "pt", "Romanian" = "ro",
      "Russian" = "ru", "Spanish" = "es", "Swahili" = "sw", "Swedish" = "sv",
      "Turkish" = "tr", "Ukrainian" = "uk", "Urdu" = "ur", "Vietnamese" = "vi"
    )

    # show modal when trigger fires
    observeEvent(trigger(), {
      # open modal with selectInput and Save/Cancel
      showModal(
        modalDialog(
          title = "Application settings",
          selectInput(ns("select_language"), "Choose language:", choices = lang_choices, selected = general_settings_rv()$language),
          footer = tagList(
            modalButton("Cancel"),
            actionButton(ns("save_settings"), "Save", class = "btn btn-primary")
          ),
          easyClose = TRUE,
          size = "m"
        )
      )
    }, ignoreInit = TRUE)

    # Save settings
    observeEvent(input$save_settings, {
      req(input$select_language)
      general_settings_rv(list(language = input$select_language))
      # try to set AMR package locale
      tryCatch({
        AMR::set_AMR_locale(input$select_language)
        language_name <- names(lang_choices[lang_choices == input$select_language])
        showNotification(paste("Language set to", language_name), type = "message")
      }, error = function(e) {
        showNotification(paste("Could not set language:", e$message), type = "warning")
      })
      removeModal()
    })

    # Return reactive list
    return(list(general_settings = reactive({ general_settings_rv() })))
  })
}
