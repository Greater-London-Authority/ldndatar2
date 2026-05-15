####################### URL for the London Datastore API #######################
#' @title lds_patch_description
#' @description Updates description page of an existing dataset on the London Datastore/.
#' @param slug A character, url slug of the dataset - https://data.london.gov.uk/dataset/<slug>
#' @param patch A character, output of `lds_description_render()`
#' @param api_key A character. London Datastore API key - needed to amend a dataset.
#' @return A response object
#' @examples
#' \dontrun{
#' new_description <- lds_description_render("datastore_description.Rmd", save_html = FALSE)
#' lds_patch_description(slug = "2o8xw", patch = new_description, api_key = Sys.getenv("LDS_API_KEY"))
#' }
#' @rdname lds_patch_description
#' @importFrom checkmate assert_string
#' @importFrom httr2 request req_method req_headers req_body_json req_perform resp_check_status
#' @export
lds_patch_description <- function(slug, patch, api_key) {
  checkmate::assert_string(slug)
  checkmate::assert_string(api_key)
  checkmate::assert_string(patch)

  url <- paste0(lds_api_url, "dataset/", slug)

  body <- list(list(
    op = "replace",
    path = "/description",
    value = patch
  ))

  resp <- httr2::request(url) |>
    httr2::req_method("PATCH") |>
    httr2::req_headers(
      Authorization = api_key,
      "Content-Type" = "application/json-patch+json"
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_perform()

  httr2::resp_check_status(resp)
}
