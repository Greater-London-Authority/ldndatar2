#' @title lds_meta_data
#' @description Fetch all available meta data
#'
#'
#' @param type <character> The type of meta data to be returned "resources", "datasets", "teams" or "topics"
#' @importFrom checkmate assert_choice
#' @importFrom glue glue
#' @export
lds_meta_data <- function(type = "resources") {
  checkmate::assert_choice(type, c("resources", "datasets", "teams", "topics"))

  if (type %in% c("resources", "datasets")) {
    fetch_tabular_metadata(type)
  } else if (type == "teams") {
    fetch_team_metadata()
  } else {
    fetch_topic_metadata()
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

#' @title fetch_team_metadata
#' @noRd
#' @description Fetch team data, previously called orgs
#'
#' @importFrom glue glue
fetch_team_metadata <- function() {
  url <- glue::glue("{lds_url_api}v3/datasets/export.json")

  resp <- url |>
    httr2::request() |>
    httr2::req_perform()

  httr2::resp_check_status(resp)

  res <- httr2::resp_body_json(resp)

  rows <- lapply(res, \(x) {
    data.frame(
      id = x[["team"]][["id"]],
      title = x[["team"]][["title"]]
    )
  })

  output <- do.call(rbind, rows)

  return(output[!duplicated(output), ])
}

#' @title fetch_team_metadata
#' @noRd
#' @description Fetch unique team data
#'
#' @importFrom glue glue
fetch_topic_metadata <- function() {
  url <- glue::glue("{lds_url_api}v3/datasets/export.json")

  resp <- url |>
    httr2::request() |>
    httr2::req_perform()

  httr2::resp_check_status(resp)

  res <- httr2::resp_body_json(resp)

  rows <- unlist(lapply(res, \(x) {
    x[["topics"]]
  }))

  output <- unique(
    data.frame(
      id = unname(rows[grepl("id", names(rows))]),
      title = unname(rows[grepl("title", names(rows))])
    )
  )

  rownames(output) <- NULL

  return(output)
}
