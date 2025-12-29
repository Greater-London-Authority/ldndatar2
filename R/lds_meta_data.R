#' @title lds_meta_data
#' @description Fetch all available meta data
#'
#'
#' @param type <character> The type of meta data to be returned "resources", "orgs", "datasets" or "topics"
#' @example example_function()
#' @import dplyr glue lubridate purrr readr tidyselect stringr
#' @import pkg
#' @importFrom checkmate assert_choice
#' @importFrom glue glue
#' @export
lds_meta_data <- function(type = "resources") {
  checkmate::assert_choice(type, c("resources", "datasets"))

  if (type %in% c("resources", "datasets")) {
    fetch_tabular_metadata(type)
  }
}

#' @title fetch_tabular_metadata
#' @noRd
#' @description Fetch resources and datasets metadata
#'
#' @param type A character
#' @importFrom checkmate assert_choice
#' @importFrom glue glue
#' @importFrom dplyr mutate across contains
#' @importFrom lubridate ymd_hms ym
#' @importFrom janitor clean_names
fetch_tabular_metadata <- function(type) {
  checkmate::assert_choice(type, c("resources", "datasets"))

  meta_data_url <- glue::glue("{lds_url_api}datasets/export.{type}.csv")

  # Parse date columns for resources / datasets
  meta_data <- readr::read_csv(meta_data_url, show_col_types = FALSE) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::contains(c("At", "time"), ignore.case = FALSE),
        ~ lubridate::ymd_hms(.x, quiet = TRUE)
      )
    ) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::contains("temporal", ignore.case = FALSE),
        ~ lubridate::ym(.x, quiet = TRUE)
      )
    ) |>
    janitor::clean_names(case = "snake")

  return(meta_data)
}
fetch_org_metadata <- function(x) {}
fetch_topic_metadata <- function(x) {}
