#' @title Replace a resource in a London Datastore dataset
#'
#' @description
#' Replaces a resource (file) in the London Datastore dataset.
#' This function should be use to replace files with with the same name (title).
#' If file names don't match, user is encourage to call `lds_add_resource` instead.
#' For security reasons, it requires file name and id, and it prompts the user to confirm operation.
#' Requires an API key with write access.
#'
#' @param file_path A character - path where file to replace is located.
#' @param slug URL slug of the dataset – `https://data.london.gov.uk/dataset/<slug>`.
#' @param resource_name A character - the name of the file to be deleted.
#' @param resource_id A character, the resource id.
#' @param api_key London Datastore API key (required for write operations).
#'
#' @return The parsed JSON response from the API (invisibly).
#'
#' @examples
#' \dontrun{
#' lds_replace_resource(
#'   file_path = "path/to/my_data.csv",
#'   slug = "my-dataset",
#'   resource_name = "my_data.csv",
#'   resource_id = "xxx",
#'   api_key = Sys.getenv("LDS_API_KEY"),
#' )
#' }
#'
#' @export
#' @rdname lds_replace_resource
#' @importFrom checkmate assert_file_exists assert_string
#' @importFrom httr2 request req_method req_headers req_body_multipart req_perform resp_check_status
#' @importFrom curl form_file
lds_replace_resource <- function(
  file_path,
  slug,
  resource_name,
  resource_id,
  api_key
) {
  checkmate::assert_file_exists(file_path)
  checkmate::assert_string(slug, n.char = 5)
  checkmate::assert_string(resource_name)
  checkmate::assert_string(resource_id)
  checkmate::assert_string(api_key)

  # Check that resource exits
  all_metadata <- lds_metadata(type = "resources")
  resource_metadata <- all_metadata[
    all_metadata$dataset_id == slug & all_metadata$title == resource_name,
  ]

  if (nrow(resource_metadata) == 0) {
    stop("Resource not found, check inputs.")
  }

  # Check the names of the files match, if they don't user should use add / remove functionality
  file_name <- basename(file_path)
  datastore_file_name <- resource_metadata$title

  if (file_name != datastore_file_name) {
    stop("File names don't match, use `lds_add_resource` or check file name.")
  }

  confirmation <- readline(paste(
    "Are you sure you want to replace",
    file_name,
    "? \n1. Yes\n2. No \n\n"
  ))

  if (confirmation == 1) {
    url <- paste0(lds_url_api, "dataset/", slug, "/resources/", resource_id)
    req <- httr2::request(url)

    response <- req |>
      httr2::req_method("POST") |>
      httr2::req_headers(
        Authorization = api_key,
      ) |>
      httr2::req_body_multipart(file = curl::form_file(file_path)) |>
      httr2::req_perform()

    httr2::resp_check_status(response)
    print(paste("Resource", file_name, "updated successfully."))
  } else if (confirmation == 2) {
    stop("Operation aborted.")
  } else {
    stop("Invalid option.")
  }
  invisible(response)
}
