#' @title Download a dataset resource
#' @description Downloads resource using URL for a specified resource.
#' This function replaces the `lds_resource_url` from the original `ldndatar` package.
#' Because of the new authentication the file has to be downloaded after the request.
#' @param slug A URL slug of the dataset - https://data.london.gov.uk/dataset/<slug>
#' @param dir Where to save the output. Default: current working directory
#' @param res_title The title of the resource, Default: NULL
#' @param res_id The ID of the resource, Default: NULL
#' @param api_key London Datastore API key, only needed for private datasets, Default: NULL
#' @return The path of the downloaded file (invisibly).
#' @export
lds_download_resource <- function(
  slug,
  dir = getwd(),
  res_title = NULL,
  res_id = NULL,
  api_key = NULL
) {
  # Input validation
  checkmate::assert_string(slug, n.chars = 5L)
  checkmate::assert_directory_exists(dir)
  checkmate::assert_string(res_title, null.ok = TRUE)
  checkmate::assert_string(res_id, null.ok = TRUE)
  checkmate::assert_string(api_key, null.ok = TRUE)

  # Get metadata
  meta_data <- lds_download_metadata(slug, api_key)
  private_dataset <- any(unique(meta_data$sharing) %in% c("private", "draft"))

  if (!"resource_id" %in% names(meta_data)) {
    stop("This dataset has no resources")
  }

  if ("order" %in% names(meta_data)) {
    meta_data <- dplyr::arrange(meta_data, .data$order)
  }

  # Filter metadata based on res_title and res_id
  res_data <- meta_data |>
    (\(df) {
      if (!is.null(res_title)) {
        dplyr::filter(df, .data$resource_title == res_title)
      } else {
        df
      }
    })() |>
    (\(df) {
      if (!is.null(res_id)) {
        dplyr::filter(df, .data$resource_id == res_id)
      } else {
        df
      }
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
  path <- file.path(dir, file)

  dataset_url <- glue::glue("{lds_url}/download/{slug}/{res_id}/{file}")
  req <- httr2::request(dataset_url)

  if (private_dataset) {
    req <- req |>
      httr2::req_headers(Authorization = api_key)
  }

  httr2::req_perform(req, path = path)

  return(invisible(path))
}
