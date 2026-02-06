#' @title Add a resource to a London Datastore dataset
#'
#' @description
#' Uploads a file as a new resource to an existing dataset on the London
#' Datastore. Requires an API key with write access.
#'
#' @param file_path Path to the file to upload.
#' @param slug URL slug of the dataset –
#'   `https://data.london.gov.uk/dataset/<slug>`.
#' @param api_key London Datastore API key (required for write operations).
#' @param res_title Resource title. If `NULL`, the file name is used.
#'   Default: `NULL`.
#' @param description Description of the resource. Default: `NULL`.
#' @param temporal_coverage_from Optional start date (`Date` or `character`).
#'   Default: `NULL`.
#' @param temporal_coverage_to Optional end date (`Date` or `character`).
#'   Default: `NULL`.
#' @param update_timestamp Whether to set the dataset's "updated at" timestamp
#'   to the current time after upload. Default: `TRUE`.
#'
#' @return The parsed JSON response from the API (invisibly).
#'
#' @examples
#' \dontrun{
#' lds_add_resource(
#'   file_path = "data/my_data.csv",
#'   slug = "my-dataset",
#'   api_key = Sys.getenv("LDS_API_KEY"),
#'   res_title = "My Data CSV",
#'   description = "Monthly counts of things"
#' )
#' }
#'
#' @export
#' @rdname lds_add_resource
#' @importFrom checkmate assert_file_exists assert_string assert_date
#'   assert_logical
#' @importFrom glue glue
#' @importFrom stringr str_extract
#' @importFrom dplyr pull filter
#' @importFrom rlang .data
lds_add_resource <- function(file_path,
                             slug,
                             api_key,
                             res_title = NULL,
                             description = NULL,
                             temporal_coverage_from = NULL,
                             temporal_coverage_to = NULL,
                             update_timestamp = TRUE) {
  # ---- Input validation ----
  checkmate::assert_file_exists(file_path)
  checkmate::assert_string(slug, min.chars = 1L)
  checkmate::assert_string(api_key, min.chars = 1L)
  checkmate::assert_string(res_title, null.ok = TRUE, min.chars = 1L)
  checkmate::assert_string(description, null.ok = TRUE)
  checkmate::assert_logical(update_timestamp, len = 1L, any.missing = FALSE)

  if (!is.null(temporal_coverage_from)) {
    checkmate::assert(
      checkmate::check_date(temporal_coverage_from),
      checkmate::check_string(temporal_coverage_from, min.chars = 1L),
      combine = "or"
    )
  }

  if (!is.null(temporal_coverage_to)) {
    checkmate::assert(
      checkmate::check_date(temporal_coverage_to),
      checkmate::check_string(temporal_coverage_to, min.chars = 1L),
      combine = "or"
    )
  }

  # ---- Check the dataset exists and warn if not private ----
  meta_dataset <- lds_download_metadata(slug, api_key)

  sharing_status <- meta_dataset |>
    dplyr::pull(.data$sharing) |>
    unique()

  if (!any(sharing_status %in% c("private", "draft"))) {
    warning("This is not a private dataset.")
  }


  # ---- Derive resource title from file name if not provided ----
  if (is.null(res_title)) {
    res_title <- stringr::str_extract(file_path, "[^/]+$")
  }

  # Warn if a resource with this title already exists
  if ("resource_title" %in% names(meta_dataset)) {
    existing_titles <- meta_dataset |>
      dplyr::pull(.data$resource_title)

    if (res_title %in% existing_titles) {
      warning(
        "A resource with this title already exists. ",
        "If you meant to replace it, use lds_replace_resource()."
      )
    }
  }

  # ---- Build multipart body ----
  body <- list(
    title = res_title,
    file  = curl::form_file(file_path)
  )

  if (!is.null(description)) {
    body[["description"]] <- description
  }

  if (!is.null(temporal_coverage_from)) {
    body[["temporal_coverage_from"]] <- as.character(temporal_coverage_from)
  }

  if (!is.null(temporal_coverage_to)) {
    body[["temporal_coverage_to"]] <- as.character(temporal_coverage_to)
  }

  # ---- POST the resource ----
  resource_url <- glue::glue("{lds_url_api}dataset/{slug}/resources")

  response <- httr2::request(resource_url) |>
    httr2::req_headers(Authorization = api_key) |>
    httr2::req_body_multipart(!!!body) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  resp_status <- httr2::resp_status(response)

  if (resp_status == 403) {
    stop("Access denied. Check that your API key has write permissions.")
  } else if (resp_status == 404) {
    stop(glue::glue("Dataset with slug '{slug}' was not found."))
  } else if (resp_status >= 400) {
    stop(
      glue::glue(
        "Failed to add resource (HTTP {resp_status}): ",
        "{httr2::resp_body_string(response)}"
      )
    )
  }

  # ---- Optionally update the dataset timestamp ----
  if (update_timestamp) {
    lds_patch_dataset_timestamp(slug, api_key)
  }

  invisible(httr2::resp_body_json(response))
}


# ---- Internal helper: PATCH dataset updated_at timestamp ----

#' Update a dataset's "updated at" timestamp
#'
#' Sends a PATCH request to the London Datastore API to set the dataset's
#' `updated_at` field to the current time.
#'
#' @param slug URL slug of the dataset.
#' @param api_key London Datastore API key.
#'
#' @return The HTTP response (invisibly).
#' @noRd
lds_patch_dataset_timestamp <- function(slug, api_key) {
  patch_url <- glue::glue("{lds_url_api}dataset/{slug}")

  patch_body <- list(
    updated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
  )

  response <- httr2::request(patch_url) |>
    httr2::req_headers(Authorization = api_key) |>
    httr2::req_method("PATCH") |>
    httr2::req_body_json(patch_body) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  resp_status <- httr2::resp_status(response)

  if (resp_status >= 400) {
    warning(
      glue::glue(
        "Failed to update dataset timestamp (HTTP {resp_status}). ",
        "The resource was added successfully."
      )
    )
  }

  invisible(response)
}
