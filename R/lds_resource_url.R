#' @title lds2_resource_url
#' @description Retrieves the URL for a specified resource in a dataset from the London Datastore.
#' This function is dependent on the ld2_download_metadata() function
#' @param slug A URL slug of the dataset - https://data.london.gov.uk/dataset/<slug>
#' @param res_title The title of the resource, Default: NULL
#' @param res_id The ID of the resource, Default: NULL
#' @param api_key London Datastore API key, only needed for private datasets, Default: NULL
#' @return A URL string of the resource
#' @export
#' @import checkmate
#' @import dplyr
#' @import stringr
#' @import httr
#' @import tibble
#' @importFrom glue glue
lds_resource_url <- function(
  slug,
  res_title = NULL,
  res_id = NULL,
  api_key = NULL
) {
  # Checks
  checkmate::assert_string(slug)
  checkmate::assert_string(res_title, null.ok = TRUE)
  checkmate::assert_string(res_id, null.ok = TRUE)
  checkmate::assert_string(api_key, null.ok = TRUE)

  # Get metadata
  meta_data <- lds_download_metadata(slug, api_key)
  private_dataset <- any(unique(meta_data$sharing) %in% c("private", "draft"))

  # Filter metadata based on res_title and res_id
  res_data <- meta_data |>
    dplyr::arrange(order) |>
    (\(df) {
      if (!is.null(res_title)) {
        dplyr::filter(df, resource_title == res_title)
      } else {
        df
      }
    })() |>
    (\(df) {
      if (!is.null(res_id)) dplyr::filter(df, resource_id == res_id) else df
    })() |>
    dplyr::slice_head(n = 1)

  if (nrow(res_data) == 0) {
    stop("Specified resource not available")
  } else {
    res_data <- as.list(res_data)
  }

  if (is.null(res_id)) {
    res_id <- res_data$resource_id
  }
  file <- stringr::str_extract(res_data$url, "[^/]+$")

  url <- glue::glue("{lds_url}/download/{slug}/{res_id}/{file}")

  # For private datasets, follow the redirect
  if (private_dataset) {
    response <- httr::GET(
      url,
      config = httr::add_headers(Authorization = api_key)
    )
    return(httr::content(response, as = "text"))
  }
}
