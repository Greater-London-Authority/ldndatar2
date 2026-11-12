#' @title Delete a resource in a London Datastore dataset
#'
#' @description
#' Deletes a resource (file) on the London Datastore dataset.
#' For security reasons, it requires file name and id, and it prompts the user to confirm operation.
#' Requires an API key with write access.
#'
#' @param slug URL slug of the dataset - `https://data.london.gov.uk/dataset/<slug>`.
#' @param resource_name A character, the name of the file to be deleted.
#' @param resource_id A character, the resource id.
#' @param api_key London Datastore API key (required for write operations).
#'
#' @return The httr2 response (invisibly).
#'
#' @examples
#' \dontrun{
#' lds_delete_resource(
#'   resource_name = "my_data.csv",
#'   slug = "2o8xw",
#'   resource_id = "xxx",
#'   api_key = Sys.getenv("LDS_API_KEY")
#' )
#' }
#'
#' @export
#' @rdname lds_delete_resource
#' @importFrom checkmate assert_string
#' @importFrom httr2 request req_method req_headers req_body_json req_perform resp_check_status
lds_delete_resource <- function(slug, resource_name, resource_id, api_key) {
  checkmate::assert_string(slug, n.chars = 5L)
  checkmate::assert_string(resource_name)
  checkmate::assert_string(resource_id)
  checkmate::assert_string(api_key)

  resource <- find_resource(slug, resource_name, resource_id, api_key)

  if (nrow(resource) == 0) {
    stop("Resource not found.")
  }

  confirmation <- readline(paste(
    "Are you sure you want to delete",
    resource_name,
    "? \n1. Yes\n2. No \n\n"
  ))

  if (confirmation == 1) {
    url <- paste0(lds_url_api, "dataset/", slug)

    req <- httr2::request(url)

    response <- req |>
      httr2::req_method("PATCH") |>
      httr2::req_headers(
        Authorization = api_key,
        "Content-Type" = "application/json-patch+json"
      ) |>
      httr2::req_body_json(list(list(
        op = "remove",
        path = paste0("/resources/", resource_id)
      ))) |>
      httr2::req_perform()

    httr2::resp_check_status(response)

    lds_patch_dataset_timestamp(slug = slug, api_key = api_key)

    message("Resource ", resource_name, " deleted successfully.")
  } else if (confirmation == 2) {
    stop("Deletion aborted.")
  } else {
    stop("Invalid option.")
  }
  invisible(response)
}

#' Find a resource on a dataset
#'
#' Looks the resource up in the dataset's own metadata, using the API key, so
#' resources on private datasets are found too.
#'
#' @param slug URL slug of the dataset.
#' @param resource_name The resource title.
#' @param resource_id The resource id.
#' @param api_key London Datastore API key.
#' @return The matching rows of the dataset metadata, possibly none.
#' @noRd
find_resource <- function(slug, resource_name, resource_id, api_key) {
  meta_data <- lds_download_metadata(slug, api_key)

  if (!all(c("resource_id", "resource_title") %in% names(meta_data))) {
    return(meta_data[0, ])
  }

  meta_data[
    which(
      meta_data$resource_id == resource_id &
        meta_data$resource_title == resource_name
    ),
  ]
}
