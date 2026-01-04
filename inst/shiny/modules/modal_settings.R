# Module for app settings modal

# Server for settings module
# trigger: a reactive that signals when to open the modal (e.g. reactive(input$settings_button))
# Returns: list(general_settings = reactive({ list(language = <code>) }))
modal_settings_server <- function(id, trigger) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # reactiveVal to store settings
    settings <- reactiveVal(list(
      language = AMR::get_AMR_locale(),
      guideline = getOption("AMR_guideline"),
      eucast_rules = getOption("AMR_eucast_rules"),
      keep_synonyms = getOption("AMR_keep_synonyms"),
      include_PKPD = getOption("AMR_include_PKPD"),
      breakpoint_type = getOption("AMR_breakpoint_type"),
      capped_mic_handling = getOption("AMR_capped_mic_handling"),
      include_screening = getOption("AMR_include_screening")
    ))

    # language choices
    choices <- list(
      language = c(
        "English" = "en", "Arabic" = "ar", "Bengali" = "bn", "Chinese" = "zh",
        "Czech" = "cs", "Danish" = "da", "Dutch" = "nl", "Finnish" = "fi",
        "French" = "fr", "German" = "de", "Greek" = "el", "Hindi" = "hi",
        "Indonesian" = "id", "Italian" = "it", "Japanese" = "ja", "Korean" = "ko",
        "Norwegian" = "no", "Polish" = "pl", "Portuguese" = "pt", "Romanian" = "ro",
        "Russian" = "ru", "Spanish" = "es", "Swahili" = "sw", "Swedish" = "sv",
        "Turkish" = "tr", "Ukrainian" = "uk", "Urdu" = "ur", "Vietnamese" = "vi"
      ),
      guideline = c("EUCAST", "CLSI", "None"),
      eucast_rules = c(
        "breakpoints", "expected_phenotypes", "expert", "other", "all"
      ),
      keep_synonyms = c(TRUE, FALSE),
      include_PKPD = c(TRUE, FALSE),
      breakpoint_type = c("ECOFF", "animal", "human"),
      capped_mic_handling = c("standard", "strict", "relaxed", "inverse"),
      include_screening = c(TRUE, FALSE)
    )

    # show modal when trigger fires
    observeEvent(trigger(),
      {
        # open modal with selectInput and Save/Cancel
        showModal(
          modalDialog(
            title = "Application settings",
            selectInput(
              ns("select_language"), "Choose language:",
              choices = choices$language, selected = settings()$language
            ),
            selectInput(
              ns("select_guideline"), "Default guideline for as.sir():",
              choices = choices$guideline, selected = settings()$guideline
            ),
            selectInput(
              ns("select_eucast_rules"), "Default eucast_rules for eucast_rules():",
              choices = choices$eucast_rules, selected = settings()$eucast_rules
            ),
            checkboxInput(
              ns("keep_synonyms"), "Keep synonyms in as.mo() and all mo_* functions",
              value = settings()$keep_synonyms
            ),
            checkboxInput(
              ns("include_PKPD"), "Include PK/PD breakpoints in as.sir()",
              value = settings()$include_PKPD
            ),
            selectInput(
              ns("select_breakpoint_type"), "Default breakpoint type for as.sir():",
              choices = choices$breakpoint_type, selected = settings()$breakpoint_type
            ),
            selectInput(
              ns("select_capped_mic_handling"), "Default capped MIC handling for as.sir():",
              choices = choices$capped_mic_handling, selected = settings()$capped_mic_handling
            ),
            checkboxInput(
              ns("include_screening"), "Include screening breakpoints in as.sir()",
              value = settings()$include_screening
            ),
            footer = tagList(
              modalButton("Cancel"),
              actionButton(ns("save_settings"), "Save", class = "btn btn-primary")
            ),
            easyClose = TRUE,
            size = "m"
          )
        )
      },
      ignoreInit = TRUE
    )

    # Save settings
    observeEvent(input$save_settings, {
      req(input$select_language)
      settings(list(
        language = input$select_language,
        guideline = input$select_guideline,
        eucast_rules = input$select_eucast_rules,
        keep_synonyms = input$keep_synonyms,
        include_PKPD = input$include_PKPD,
        breakpoint_type = input$select_breakpoint_type,
        capped_mic_handling = input$select_capped_mic_handling,
        include_screening = input$include_screening
      ))
      # try to set AMR package locale
      tryCatch(
        {
          AMR::set_AMR_locale(input$select_language)
          options(
            AMR_locale = input$select_language,
            AMR_guideline = input$select_guideline,
            AMR_eucast_rules = input$select_eucast_rules,
            AMR_keep_synonyms = input$keep_synonyms,
            AMR_include_PKPD = input$include_PKPD,
            AMR_breakpoint_type = input$select_breakpoint_type,
            AMR_capped_mic_handling = input$select_capped_mic_handling,
            AMR_include_screening = input$include_screening
          )
          language_name <- names(choices$language[choices$language == input$select_language])
          showNotification(paste("Language set to", language_name), type = "message")
        },
        error = function(e) {
          showNotification(paste("Could not set language:", e$message), type = "warning")
        }
      )
      removeModal()
    })

    # Return reactive list
    list(general_settings = reactive({
      settings()
    }))
  })
}
