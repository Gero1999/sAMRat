#' Create an AMR-ready object by converting selected columns
#'
#' This helper converts specified columns in a data.frame to AMR-friendly
#' types using the [AMR] package (for example `as.mo()`, `as.sir()`,
#' `as.mic()`, `as.disk()`) and collects metadata for microorganisms and
#' antimicrobials. It will also attempt to coerce a date column to `Date`
#' using common formats and can optionally filter to the first isolate per
#' subject and microorganism.
#'
#' The returned object is a list with at least a `data` element (the
#' transformed data.frame). When a microorganism column is provided, a
#' `mo` sub-list with naming, traits, taxonomy and details is included.
#' When antibiotic columns are provided a corresponding `ab` sub-list is
#' returned with group and details information.
#'
#' @param df A data.frame containing the raw isolate or susceptibility
#'   data.
#' @param mo_col Character (single) name of the microorganism column in
#'   `df`. If provided, values are coerced with `as.mo()` and
#'   microorganism metadata is returned.
#' @param sir_cols Character vector of column names containing S/I/R
#'   results. Each found column will be coerced with `as.sir()`.
#' @param mic_cols Character vector of column names containing MIC
#'   results. Each found column will be coerced with `as.mic()`.
#' @param disk_cols Character vector of column names containing disk
#'   diffusion results. Each found column will be coerced with
#'   `as.disk()`.
#' @param date_col Character (single) name of a date column. The function
#'   will try a few common formats and coerce the column to `Date`.
#' @param subject_col Character (single) name of the column used as
#'   subject/patient identifier. If provided a `SUBJID` factor column is
#'   added to the returned data.
#' @param filter_first_isolate Logical, if `TRUE` the data is filtered to
#'   only the first isolate per subject x microorganism (earliest date).
#'   The function uses `dplyr::filter()` with an internal helper and will
#'   fall back to returning the unfiltered data on error.
#'
#' @return A named list with at least:
#'   * `data`: the transformed `data.frame`.
#'   * `mo` (optional): list with `naming`, `traits`, `taxonomy`, and
#'     `details` data.frames for the microorganism column.
#'   * `ab` (optional): list with `group`, `details`, `atc`, `tradenames`
#'     and `loinc` information for antibiotic columns.
#'
#' @details This function wraps a number of convenience conversions from
#'   the [AMR] package. It uses `try()`/`tryCatch()` in several places to
#'   avoid hard failures for partial or unexpected inputs.
#'
#' @examples
#'
#' # Minimal example (requires the AMR package):
#' if (requireNamespace("AMR", quietly = TRUE)) {
#'   df <- data.frame(
#'     mo = c("Escherichia coli", "Staphylococcus aureus"),
#'     AMP = c("R", "S"),
#'     date = c("2020-01-01", "2020-01-02"),
#'     id = c("p1", "p2"),
#'     stringsAsFactors = FALSE
#'   )
#'   create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date", subject_col = "id")
#' }
#'
#' @seealso [as.mo()], [as.sir()], [as.mic()], [as.disk()]
#' @export
#' @importFrom magrittr %>%
#' @importFrom AMR first_isolate ab_info as.ab is_sir_eligible mo_fullname mo_shortname mo_current mo_gramstain mo_pathogenicity mo_oxygen_tolerance mo_type mo_species mo_genus mo_family mo_order mo_class mo_phylum mo_kingdom mo_gbif mo_url
create_amr_obj <- function(df,
                           mo_col = NULL,
                           sir_cols = NULL,
                           mic_cols = NULL,
                           disk_cols = NULL,
                           date_col = NULL,
                           subject_col = NULL,
                           filter_first_isolate = FALSE) {
  stopifnot(is.data.frame(df))
  amr_df <- df

  # helper to check existence
  has_col <- function(x) !is.null(x) && x %in% names(amr_df)

  # MO column
  if (!is.null(mo_col) && mo_col %in% names(amr_df)) {
    try(
      {
        amr_df[[mo_col]] <- as.mo(amr_df[[mo_col]])
      },
      silent = TRUE
    )
  }

  # SIR columns
  if (!is.null(sir_cols) && length(sir_cols) > 0) {
    for (col in sir_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.sir(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # MIC columns
  if (!is.null(mic_cols) && length(mic_cols) > 0) {
    for (col in mic_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.mic(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # Disk columns
  if (!is.null(disk_cols) && length(disk_cols) > 0) {
    for (col in disk_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.disk(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # Date column: try to coerce to Date with common formats
  if (!is.null(date_col) && date_col != "None" && date_col %in% names(amr_df)) {
    d <- amr_df[[date_col]]
    if (!inherits(d, "Date")) {
      # try common formats
      parsed <- try(as.Date(d), silent = TRUE)
      if (inherits(parsed, "try-error") || all(is.na(parsed))) {
        parsed <- try(as.Date(d, format = "%Y-%m-%d"), silent = TRUE)
      }
      if (inherits(parsed, "try-error") || all(is.na(parsed))) {
        parsed <- try(as.Date(d, format = "%d/%m/%Y"), silent = TRUE)
      }
      if (!(inherits(parsed, "try-error"))) {
        amr_df[[date_col]] <- parsed
      }
    }
  }

  # Subject column -> SUBJID factor
  if (!is.null(subject_col) && subject_col != "None" && subject_col %in% names(amr_df)) {
    amr_df$SUBJID <- as.factor(amr_df[[subject_col]])
  }

  # Optional: filter first isolate per patient x microorganism (earliest date)
  if (isTRUE(filter_first_isolate)) {
    amr_df <- tryCatch(
      {
        amr_df %>%
          dplyr::filter(
            first_isolate(col_mo = mo_col, col_date = date_col, col_subjid = "SUBJID")
          )
      },
      error = function(e) {
        warning(sprintf("first_isolate filter failed: %s", e$message), call. = FALSE)
        # return unfiltered data so the rest of the processing continues
        amr_df
      }
    )
  }

  amr_obj <- list(data = amr_df)

  # Produce additional properties for the microorganism column (mo)
  if (!is.null(mo_col) && mo_col %in% names(amr_df)) {
    mo_vals <- amr_df[[mo_col]]

    amr_obj$mo <- list(
      naming = data.frame(
        mo = mo_vals,
        fullname = mo_fullname(mo_vals),
        short = mo_shortname(mo_vals),
        current = mo_current(mo_vals)
      ),
      traits = data.frame(
        mo = mo_vals,
        gram_stain = mo_gramstain(mo_vals),
        pathogenicity = mo_pathogenicity(mo_vals),
        oxygen_tolerance = mo_oxygen_tolerance(mo_vals),
        type = mo_type(mo_vals)
      ),
      taxonomy = data.frame(
        mo = mo_vals,
        species = mo_species(mo_vals),
        genus = mo_genus(mo_vals),
        family = mo_family(mo_vals),
        order = mo_order(mo_vals),
        class = mo_class(mo_vals),
        phylum = mo_phylum(mo_vals),
        kingdom = mo_kingdom(mo_vals)
      ),
      details = data.frame(
        mo = mo_vals,
        gbif = mo_gbif(mo_vals),
        url = mo_url(mo_vals)
      )
    )
  }

  # Produce additional properties for the antibiotic columns (ab)
  ab_cols <- c(sir_cols, mic_cols, disk_cols)
  ab_cols <- unique(ab_cols[!ab_cols %in% c(NULL, "None")])
  if (!is.null(ab_cols)) {
    ab_vals <- as.ab(ab_cols)
    col_types <- ifelse(ab_cols %in% sir_cols, "SIR",
      ifelse(ab_cols %in% mic_cols, "MIC",
        ifelse(ab_cols %in% disk_cols, "Disk", NA)
      )
    )
    ab_info <- ab_info(ab_vals)

    amr_obj$ab <- list(
      group = data.frame(
        col = ab_cols,
        ab = as.character(ab_vals),
        name = ab_info$name,
        group = ab_info$group,
        atc_group1 = ab_info$atc_group1,
        atc_group2 = ab_info$atc_group2
      ),
      details = data.frame(
        ab = ab_cols,
        ab_val = as.character(ab_vals),
        ddd_oral_amount = ab_info$ddd$oral$amount,
        ddd_oral_units = ab_info$ddd$oral$units,
        ddd_iv_amount = ab_info$ddd$iv$amount,
        ddd_iv_units = ab_info$ddd$iv$units
      ),
      atc = ab_info$atc,
      tradenames <- ab_info$tradenames,
      loinc <- ab_info$loinc
    )
  }
  return(amr_obj)
}
#' Create an AMR-ready object by converting selected columns
#'
#' This helper converts specified columns in a data.frame to AMR-friendly
#' types using the [AMR] package (for example `as.mo()`, `as.sir()`,
#' `as.mic()`, `as.disk()`) and collects metadata for microorganisms and
#' antimicrobials. It will also attempt to coerce a date column to `Date`
#' using common formats and can optionally filter to the first isolate per
#' subject and microorganism.
#'
#' The returned object is a list with at least a `data` element (the
#' transformed data.frame). When a microorganism column is provided, a
#' `mo` sub-list with naming, traits, taxonomy and details is included.
#' When antibiotic columns are provided a corresponding `ab` sub-list is
#' returned with group and details information.
#'
#' @param df A data.frame containing the raw isolate or susceptibility
#'   data.
#' @param mo_col Character (single) name of the microorganism column in
#'   `df`. If provided, values are coerced with `as.mo()` and
#'   microorganism metadata is returned.
#' @param sir_cols Character vector of column names containing S/I/R
#'   results. Each found column will be coerced with `as.sir()`.
#' @param mic_cols Character vector of column names containing MIC
#'   results. Each found column will be coerced with `as.mic()`.
#' @param disk_cols Character vector of column names containing disk
#'   diffusion results. Each found column will be coerced with
#'   `as.disk()`.
#' @param date_col Character (single) name of a date column. The function
#'   will try a few common formats and coerce the column to `Date`.
#' @param subject_col Character (single) name of the column used as
#'   subject/patient identifier. If provided a `SUBJID` factor column is
#'   added to the returned data.
#' @param filter_first_isolate Logical, if `TRUE` the data is filtered to
#'   only the first isolate per subject x microorganism (earliest date).
#'   The function uses `dplyr::filter()` with an internal helper and will
#'   fall back to returning the unfiltered data on error.
#'
#' @return A named list with at least:
#'   * `data`: the transformed `data.frame`.
#'   * `mo` (optional): list with `naming`, `traits`, `taxonomy`, and
#'     `details` data.frames for the microorganism column.
#'   * `ab` (optional): list with `group`, `details`, `atc`, `tradenames`
#'     and `loinc` information for antibiotic columns.
#'
#' @details This function wraps a number of convenience conversions from
#'   the [AMR] package. It uses `try()`/`tryCatch()` in several places to
#'   avoid hard failures for partial or unexpected inputs.
#'
#' @examples
#'
#' # Minimal example (requires the AMR package):
#' if (requireNamespace("AMR", quietly = TRUE)) {
#'   df <- data.frame(
#'     mo = c("Escherichia coli", "Staphylococcus aureus"),
#'     AMP = c("R", "S"),
#'     date = c("2020-01-01", "2020-01-02"),
#'     id = c("p1", "p2"),
#'     stringsAsFactors = FALSE
#'   )
#'   create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date", subject_col = "id")
#' }
#'
#' @seealso [as.mo()], [as.sir()], [as.mic()], [as.disk()]
#' @export
#' @importFrom magrittr %>%
#' @importFrom AMR first_isolate ab_info as.ab is_sir_eligible mo_fullname mo_shortname mo_current mo_gramstain mo_pathogenicity mo_oxygen_tolerance mo_type mo_species mo_genus mo_family mo_order mo_class mo_phylum mo_kingdom mo_gbif mo_url
create_amr_obj <- function(df,
                           mo_col = NULL,
                           sir_cols = NULL,
                           mic_cols = NULL,
                           disk_cols = NULL,
                           date_col = NULL,
                           subject_col = NULL,
                           filter_first_isolate = FALSE) {
  stopifnot(is.data.frame(df))
  amr_df <- df

  # helper to check existence
  has_col <- function(x) !is.null(x) && x %in% names(amr_df)

  # MO column
  if (!is.null(mo_col) && mo_col %in% names(amr_df)) {
    try(
      {
        amr_df[[mo_col]] <- as.mo(amr_df[[mo_col]])
      },
      silent = TRUE
    )
  }

  # SIR columns
  if (!is.null(sir_cols) && length(sir_cols) > 0) {
    for (col in sir_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.sir(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # MIC columns
  if (!is.null(mic_cols) && length(mic_cols) > 0) {
    for (col in mic_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.mic(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # Disk columns
  if (!is.null(disk_cols) && length(disk_cols) > 0) {
    for (col in disk_cols) {
      if (!is.null(col) && col != "None" && col %in% names(amr_df)) {
        try(
          {
            amr_df[[col]] <- as.disk(amr_df[[col]])
          },
          silent = TRUE
        )
      }
    }
  }

  # Date column: try to coerce to Date with common formats
  if (!is.null(date_col) && date_col != "None" && date_col %in% names(amr_df)) {
    d <- amr_df[[date_col]]
    if (!inherits(d, "Date")) {
      # try common formats
      parsed <- try(as.Date(d), silent = TRUE)
      if (inherits(parsed, "try-error") || all(is.na(parsed))) {
        parsed <- try(as.Date(d, format = "%Y-%m-%d"), silent = TRUE)
      }
      if (inherits(parsed, "try-error") || all(is.na(parsed))) {
        parsed <- try(as.Date(d, format = "%d/%m/%Y"), silent = TRUE)
      }
      if (!(inherits(parsed, "try-error"))) {
        amr_df[[date_col]] <- parsed
      }
    }
  }

  # Subject column -> SUBJID factor
  if (!is.null(subject_col) && subject_col != "None" && subject_col %in% names(amr_df)) {
    amr_df$SUBJID <- as.factor(amr_df[[subject_col]])
  }

  # Optional: filter first isolate per patient x microorganism (earliest date)
  if (isTRUE(filter_first_isolate)) {
    amr_df <- tryCatch(
      {
        amr_df %>%
          dplyr::filter(
            first_isolate(col_mo = mo_col, col_date = date_col, col_subjid = "SUBJID")
          )
      },
      error = function(e) {
        warning(sprintf("first_isolate filter failed: %s", e$message), call. = FALSE)
        # return unfiltered data so the rest of the processing continues
        amr_df
      }
    )
  }

  amr_obj <- list(data = amr_df)

  # Produce additional properties for the microorganism column (mo)
  if (!is.null(mo_col) && mo_col %in% names(amr_df)) {
    mo_vals <- unique(amr_df[[mo_col]])

    amr_obj$mo <- list(
      naming = data.frame(
        mo = mo_vals,
        fullname = mo_fullname(mo_vals),
        short = mo_shortname(mo_vals),
        current = mo_current(mo_vals)
      ),
      traits = data.frame(
        mo = mo_vals,
        gram_stain = mo_gramstain(mo_vals),
        pathogenicity = mo_pathogenicity(mo_vals),
        oxygen_tolerance = mo_oxygen_tolerance(mo_vals),
        type = mo_type(mo_vals)
      ),
      taxonomy = data.frame(
        mo = mo_vals,
        species = mo_species(mo_vals),
        genus = mo_genus(mo_vals),
        family = mo_family(mo_vals),
        order = mo_order(mo_vals),
        class = mo_class(mo_vals),
        phylum = mo_phylum(mo_vals),
        kingdom = mo_kingdom(mo_vals)
      ),
      details = data.frame(
        mo = mo_vals,
        gbif = mo_gbif(mo_vals),
        url = mo_url(mo_vals)
      ),
      columns = list(
        mo = mo_col
      )
    )
  }

  # Produce additional properties for the antibiotic columns (ab)
  ab_cols <- c(sir_cols, mic_cols, disk_cols)
  ab_cols <- unique(ab_cols[!ab_cols %in% c(NULL, "None")])
  if (!is.null(ab_cols)) {
    ab_vals <- as.ab(ab_cols)
    col_types <- ifelse(ab_cols %in% sir_cols, "SIR",
      ifelse(ab_cols %in% mic_cols, "MIC",
        ifelse(ab_cols %in% disk_cols, "Disk", NA)
      )
    )
    ab_info <- ab_info(ab_vals)

    amr_obj$ab <- list(
      group = data.frame(
        col = ab_cols,
        ab = as.character(ab_vals),
        name = ab_info$name,
        group = ab_info$group,
        atc_group1 = ab_info$atc_group1,
        atc_group2 = ab_info$atc_group2
      ),
      details = data.frame(
        ab = ab_cols,
        ab_val = as.character(ab_vals),
        ddd_oral_amount = ab_info$ddd$oral$amount,
        ddd_oral_units = ab_info$ddd$oral$units,
        ddd_iv_amount = ab_info$ddd$iv$amount,
        ddd_iv_units = ab_info$ddd$iv$units
      ),
      atc = ab_info$atc,
      tradenames = ab_info$tradenames,
      loinc = ab_info$loinc,
      columns = list(
        sir = sir_cols,
        mic = mic_cols,
        disk = disk_cols
      )
    )
  }
  return(amr_obj)
}

#' Merge selected microorganism metadata into amr_obj$data
#'
#' @param amr_obj An object as returned by create_amr_obj()
#' @param mo_dfs Character vector of mo metadata to merge (e.g., c("naming", "traits"))
#' @return The data.frame with selected mo metadata columns merged in
#' @export
merge_mo_info <- function(amr_obj, mo_dfs = c("naming", "traits")) {
  stopifnot(is.list(amr_obj), !is.null(amr_obj$data), !is.null(amr_obj$mo))
  data <- amr_obj$data
  mo_col <- amr_obj$mo$columns$mo
  for (df_name in mo_dfs) {
    if (!is.null(amr_obj$mo[[df_name]])) {
      data <- merge(
        data,
        amr_obj$mo[[df_name]],
        by.x = mo_col,
        by.y = "mo",
        all.x = TRUE,
        suffixes = c("", paste0("_", df_name))
      )
    }
  }
  data
}
