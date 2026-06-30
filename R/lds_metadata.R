#' @title lds_metadata
#' @description Fetch all available meta data
#' @param type <character> The type of meta data to be returned "resources", "datasets", "teams" or "topics"
#' @return A dataframe.
#' @importFrom checkmate assert_choice
#' @importFrom glue glue
#' @export
lds_metadata <- function(type = "resources") {
  checkmate::assert_choice(type, c("resources", "datasets", "teams", "topics"))

  if (type %in% c("resources", "datasets")) {
    fetch_tabular_metadata(type)
  } else if (type == "teams") {
    fetch_team_metadata()
  } else if (type == "topics") {
    fetch_topic_metadata()
  }
}

#' @title fetch_tabular_metadata
#' @noRd
#' @description Fetch resources and datasets metadata
#' @param type A character
#' @return A dataframe.
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
fetch_team_metadata <- function() {
  res <- fetch_all_api_metadata()

  output <- extract_team_metadata(res)

  return(output)
}

#' @title fetch_topic_metadata
#' @noRd
#' @description Fetch unique topic data
fetch_topic_metadata <- function() {
  res <- fetch_all_api_metadata()

  output <- extract_topic_metadata(res)

  return(output)
}

#' @title fetch_all_api_metadata
#' @noRd
#' @description Fetch all api metadata
#'
#' @importFrom glue glue
#' @importFrom httr2 request req_perform resp_check_status resp_body_json
fetch_all_api_metadata <- function() {
  url <- glue::glue("{lds_url_api}v3/datasets/export.json")

  req <- url |>
    httr2::request()

  res <- req |>
    httr2::req_perform()

  httr2::resp_check_status(res)

  return(httr2::resp_body_json(res))
}

#' @title extract_topic_metadata
#' @noRd
#' @description Extract topic metadata from nested list.
extract_topic_metadata <- function(res) {
  checkmate::assert_list(res)

  rows <- unlist(lapply(res, \(x) {
    x[["topics"]]
  }))

  output <- unique(
    data.frame(
      id = unname(rows[grepl("id", names(rows))]),
      title = unname(rows[grepl("title", names(rows))])
    )
  )

  if (nrow(output) == 0) {
    stop("Bad JSON, check input.")
  }

  rownames(output) <- NULL

  return(output)
}

#' @title extract_team_metadata
#' @noRd
#' @description Extract team metadata from nested list.
extract_team_metadata <- function(res) {
  checkmate::assert_list(res)

  rows <- lapply(res, \(x) {
    data.frame(
      id = x[["team"]][["id"]],
      title = x[["team"]][["title"]]
    )
  })

  output <- do.call(rbind, rows)

  if (nrow(output) == 0) {
    stop("Bad JSON, check input.")
  }

  return(output[!duplicated(output), ])
}
