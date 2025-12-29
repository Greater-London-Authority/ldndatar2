#' @title lds_download_metadata
#' @description Adapted from the ldndatar pkg. This updated function downloads the metadata of a given page slug. i.e. will let you know metadata about given page on the London Datastore.
#' @param slug a URL slug of the dataset - https://data.london.gov.uk/dataset/<slug>
#' @param api_key London Datastore API key, only needed for private datasets, Default: NULL
#' @param inc_tables whether to include data on any tables in the dataset, Default: FALSE
#' @return A tibble of metadata
#' @export
#' @rdname lds2_meta_dataset
#' @import httr
#' @import checkmate
#' @import dplyr
#' @import tibble
#' @importFrom lubridate ymd_hms
#' @importFrom glue glue
#'
lds_download_metadata <- function(slug, api_key = NULL, inc_tables = FALSE) {
  # Checkmate type checks
  checkmate::assert_string(slug)
  checkmate::assert_string(api_key, null.ok = TRUE)
  checkmate::assert_logical(inc_tables)

  dataset_url <- glue::glue("https://data.london.gov.uk/api/dataset/{slug}")

  if (is.null(api_key)) {
    response <- dataset_url |>
      httr2::request() |>
      httr2::req_perform()
  } else {
    response <- dataset_url |>
      httr2::request() |>
      httr2::req_headers(Authorization = api_key) |>
      httr2::req_perform()
  }

  if (httr2::resp_status(response) == 200) {
    # returns a list
    content <- httr2::resp_body_json(response)
  } else if (httr2::resp_status(response) == 403) {
    if (is.null(api_key)) {
      stop("This is a private dataset, please provide an API key.")
    } else {
      stop("You do not have permission to see this dataset.")
    }
  } else if (httr2::resp_status(response) == 404) {
    stop("This dataset does not exist.")
  }

  resources <- purrr::pluck(content, "resources")

  base_meta <- content |>
    purrr::discard_at(c("resources", "readonly")) |>
    purrr::modify_at(c("tags", "topics"), \(x) paste(x)) |>
    purrr::list_flatten(name_spec = "{outer}_{inner}") |>
    purrr::compact() |>
    tibble::as_tibble_row()

  resources_df <- resources |>
    purrr::imap(\(res, res_id) {
      res |>
        purrr::discard_at("tables") |>
        purrr::list_flatten(name_spec = "{outer}_{inner}") |>
        purrr::compact() |>
        tibble::as_tibble_row() |>
        dplyr::mutate(resource_id = res_id, .before = 1)
    }) |>
    purrr::list_rbind()

  common_cols <- intersect(names(base_meta), names(resources_df))

  meta_data <- dplyr::cross_join(
    base_meta,
    resources_df |>
      dplyr::rename_with(
        \(x) paste0("resource_", x),
        dplyr::all_of(common_cols)
      )
  )

  return(meta_data)
}
